# news

# 22.04.15 updated

# 0. what do you need

PERIOD = 12 # 12시간 전 기사까지 스크랩(실제로는 좀 더 여유있게 모음)

FOLDER = paste0('C:/Users/', Sys.info()['user'], '/Documents/GitHub/KIET_831/news')

# 1. setting

setwd(FOLDER)

library(tidyverse)
library(rstudioapi)
library(RSelenium)
library(rvest)
library(lubridate)
library(openxlsx)

# 2. selenium

TERM_COMMAND <- 'java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-4.0.0-alpha-1.jar -port 4445'
terminalExecute(command = TERM_COMMAND) # 개인 컴퓨터에서 잘 안 되는 경우 java 설치, 방화벽 개인/공용 설정 권장

REMDR = remoteDriver(port = 4445, browserName = 'chrome')
REMDR$open()

# 3-1. 연합인포맥스(전체)

INFOMAX <- tibble()

for (i in 1:100) {
  
  URL_INFOMAX <- paste0('https://news.einfomax.co.kr/news/articleList.html?page=',
                        i, '&view_type=sm')
  
  REMDR$navigate(URL_INFOMAX)
  
  temp1 <- REMDR$getPageSource()
  
  temp2 <- read_html(temp1[[1]]) %>% 
    html_elements('div.list-titles') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble() %>% 
    filter(str_detect(., ''))
  
  temp3 <- read_html(temp1[[1]]) %>% 
    html_elements('div.list-dated') %>% 
    html_text() %>%
    str_split(' | ', simplify = TRUE) %>% 
    as.data.frame() %>% 
    tibble() %>% 
    rownames_to_column(var = 'V0') %>% 
    mutate(V0 = as.double(V0))
  
  temp3.1 <- temp3 %>% 
    filter(V4 == '|') %>% 
    mutate(V7 = V6) %>% 
    mutate(V6 = V5)
  
  temp3.2 <- temp3 %>% 
    filter(V4 != '|')
  
  temp3.3 <- rbind(temp3.1, temp3.2) %>% 
    select(V0, V1, V3, V6, V7) %>% 
    arrange(V0) %>% 
    filter(V0 != 31) %>% 
    mutate(V8 = ymd_hm(paste(V6, V7), tz = 'Asia/Seoul')) %>% 
    select(V0, V1, V3, V8)
  
  temp4 <- read_html(temp1[[1]]) %>% 
    html_elements('p.list-summary') %>% 
    html_elements('a') %>% 
    html_attr('href')
  
  temp4.1 <- paste0('https://news.einfomax.co.kr', temp4) %>% 
    tibble %>% 
    filter(str_detect(., 'idxno'))
  
  temp5 <- tibble(제목 = temp2$., 분야 = temp3.3$V1, 기자 = temp3.3$V3, 시각 = temp3.3$V8, 링크 = temp4.1$.) %>% 
    relocate(분야, 시각, 기자, 링크, 제목)
  
  temp5.1 <- interval(temp5$시각, now(tz = 'Asia/Seoul')) %>% 
    as.period() < hours(PERIOD)
  
  if(sum(temp5.1) == 0) break
  
  INFOMAX <- rbind(INFOMAX, temp5)
  
}

INFOMAX <- INFOMAX %>% 
  mutate(시각 = as.character(시각))

# 3-2. 뉴스핌(글로벌)

NEWSPIM <- tibble()

for (i in 0:100) {
  
  URL_NEWSPIM <- paste0('https://www.newspim.com/news/lists/?category_cd=107&page=', i*20)
  
  REMDR$navigate(URL_NEWSPIM)
  
  temp6 <- REMDR$getPageSource()
  
  temp7 <- read_html(temp6[[1]]) %>% 
    html_elements('strong.subject_h') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble() 
  
  temp8 <- read_html(temp6[[1]]) %>% 
    html_elements('p.byline') %>% 
    html_text() %>% 
    ymd_hm(tz = 'Asia/Seoul')
  
  temp9 <- read_html(temp6[[1]]) %>% 
    html_elements('article.thumbgroup') %>% 
    html_elements('a') %>% 
    html_attr('href') %>%
    tibble() %>% 
    distinct() %>% 
    slice(1:20)
  
  temp9.1 <- paste0('https://newspim.com', temp9$.) %>% 
    tibble()
  
  temp10 <- tibble(제목 = temp7$., 시각 = temp8, 링크 = temp9.1$.) %>% 
    relocate(시각, 링크, 제목)
  
  temp10.1 <- interval(temp10$시각, now(tz = 'Asia/Seoul')) %>% 
    as.period() < hours(PERIOD)
  
  if(sum(temp10.1) == 0) break
  
  NEWSPIM <- rbind(NEWSPIM, temp10)
  
}

NEWSPIM <- NEWSPIM %>% 
  mutate(시각 = as.character(시각))

# 3-3. 산업경제신문(전체)

EBN <- tibble()

for (i in 1:100) {
  
  URL_EBN <- paste0('https://www.ebn.co.kr/newslist?category1=99&page=', i)
  
  REMDR$navigate(URL_EBN)
  
  temp11 <- REMDR$getPageSource()
  
  temp12 <- read_html(temp11[[1]]) %>% 
    html_elements('h2.articleTitle') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble() 
  
  temp13 <- read_html(temp11[[1]]) %>% 
    html_elements('p.articleInfo') %>% 
    html_text() %>% 
    str_remove_all('\n') %>% 
    str_remove_all(' ') %>% 
    str_remove_all('기자') %>% 
    tibble()
  
  temp13.1 <- temp13$. %>% 
    str_split('·', simplify = TRUE) %>% 
    as.data.frame() %>% 
    tibble()
  
  temp14 <- read_html(temp11[[1]]) %>% 
    html_elements('div.articleBox') %>% 
    html_elements('a') %>% 
    html_attr('href') %>% 
    tibble() %>% 
    distinct()
  
  temp14.1 <- paste0('https://ebn.co.kr', temp14$.) %>% 
    tibble()
  
  temp15 <- tibble(제목 = temp12$.,분야 = temp13.1$V1, 기자 = temp13.1$V2, 시각 = temp13.1$V3, 링크 = temp14.1$.) %>% 
    relocate(분야, 시각, 기자, 링크, 제목)
  
  temp15.1 <- temp15$시각 %in% paste0(1:PERIOD, '시간전')
  
  temp15.2 <- temp15$시각 %in% paste0(1:60, '분전')
  
  if(sum(temp15.1, temp15.2) == 0) break
  
  EBN <- rbind(EBN, temp15)
  
}

# 3-4. 글로벌이코노믹(국제)

GLOBALECO <- tibble()

for (i in 1:100) {
  
  URL_GLOBALECO <- paste0('https://www.g-enews.com/list.php?ct=g081100&pg=', i)
  
  REMDR$navigate(URL_GLOBALECO)
  
  temp16 <- REMDR$getPageSource()
  
  temp17 <- read_html(temp16[[1]]) %>% 
    html_elements('span.elip2') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble() %>% 
    slice(3:15)
  
  temp18 <- read_html(temp16[[1]]) %>% 
    html_elements('p.e2') %>% 
    html_text() %>% 
    str_replace_all('\\.', '-') %>% 
    ymd_hm(tz = 'Asia/Seoul') %>% 
    tibble()
  
  temp19 <- read_html(temp16[[1]]) %>% 
    html_elements('a.e1') %>% 
    html_attr('href') %>% 
    tibble() %>% 
    filter(str_detect(., 'Global-Biz')) %>% 
    slice(1:13)
  
  temp20 <- tibble(제목 = temp17$., 시각 = temp18$., 링크 = temp19$.) %>% 
    relocate(시각, 링크, 제목)
  
  temp20.1 <- interval(temp20$시각, now(tz = 'Asia/Seoul')) %>% 
    as.period() < hours(PERIOD)
  
  if(sum(temp20.1) == 0) break
  
  GLOBALECO <- rbind(GLOBALECO, temp20)
  
}

GLOBALECO <- GLOBALECO %>% 
  mutate(시각 = as.character(시각))

# 3-5. 연합뉴스(세계)

YHNEWS <- tibble()

for (i in 1:100) {
  
  URL_YHNEWS <- paste0('https://www.yna.co.kr/international/all/', i)
  
  REMDR$navigate(URL_YHNEWS)
  
  temp21 <- REMDR$getPageSource()
  
  temp22 <- read_html(temp21[[1]]) %>% 
    html_elements('div.list-type038') %>% 
    html_elements('strong.tit-news') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble()
  
  temp23 <- read_html(temp21[[1]]) %>% 
    html_elements('span.txt-time') %>% 
    html_text()
  
  temp23.1 <- paste0(str_sub(today(), 1, 4), '-', temp23) %>% 
    ymd_hm(tz = 'Asia/Seoul') %>% 
    tibble()
  
  temp24 <- read_html(temp21[[1]]) %>% 
    html_elements('a.tit-wrap') %>% 
    html_attr('href')
  
  temp24.1 <- paste0('https:', temp24[1:25]) %>% 
    tibble()
  
  temp25 <- tibble(제목 = temp22$., 시각 = temp23.1$., 링크 = temp24.1$.) %>% 
    relocate(시각, 링크, 제목)
  
  temp25.1 <- interval(temp25$시각, now(tz = 'Asia/Seoul')) %>% 
    as.period() < hours(PERIOD)
  
  if(sum(temp25.1) == 0) break
  
  YHNEWS <- rbind(YHNEWS, temp25)
  
}

YHNEWS <- YHNEWS %>% 
  mutate(시각 = as.character(시각))

# 3-6. 뉴시스(국제최신)

NEWSIS <- tibble()

for (i in 1:100) {
  
  URL_NEWSIS <- paste0('https://newsis.com/int/list/?cid=10100&scid=10101&page=', i)
  
  REMDR$navigate(URL_NEWSIS)
  
  temp26 <- REMDR$getPageSource()
  
  temp27 <- read_html(temp26[[1]]) %>% 
    html_elements('p.tit') %>% 
    html_elements('a') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble() %>% 
    slice(2:21)
  
  temp28 <- read_html(temp26[[1]]) %>% 
    html_elements('p.time') %>% 
    html_text()
  
  temp28.1 <- temp28[1:20] %>% 
    str_split('기자', simplify = TRUE) %>% 
    as.data.frame() %>% 
    tibble()
  
  temp28.2 <- temp28.1$V2 %>% 
    str_replace_all('\\.', '-') %>% 
    ymd_hms(tz = 'Asia/Seoul') %>% 
    as.data.frame() %>% 
    tibble()
  
  temp29 <- read_html(temp26[[1]]) %>% 
    html_elements('p.tit') %>% 
    html_elements('a') %>% 
    html_attr('href')
  
  temp29.1 <- paste0('https://newsis.com', temp29[2:21]) %>% 
    tibble()
  
  temp30 <- tibble(제목 = temp27$., 기자 = temp28.1$V1, 시각 = temp28.2$., 링크 = temp29.1$.) %>% 
    relocate(시각, 기자, 링크, 제목)
  
  temp30.1 <- interval(temp30$시각, now(tz = 'Asia/Seoul')) %>% 
    as.period() < hours(PERIOD)
  
  if(sum(temp30.1) == 0) break
  
  NEWSIS <- rbind(NEWSIS, temp30)
  
}

NEWSIS <- NEWSIS %>% 
  mutate(시각 = as.character(시각))

# 3-7. 뉴스1(국제)

NEWS1 <- tibble()

URL_NEWS1 <- 'https://www.news1.kr/categories/?31'

REMDR$navigate(URL_NEWS1)

for (i in 2:10) {
  
  pagebutton <- REMDR$findElement(using = 'xpath', value = paste0('//*[@id="content"]/nav/ul/li[', i, ']'))
  pagebutton$clickElement()

  temp31 <- REMDR$getPageSource()
  
  temp32 <- read_html(temp31[[1]]) %>% 
    html_elements('h3.tit') %>% 
    html_text() %>% 
    str_remove_all('\"') %>% 
    tibble() %>% 
    slice(2:21)
  
  temp33 <- read_html(temp31[[1]]) %>% 
    html_elements('div.time') %>% 
    html_text() %>% 
    tibble()
  
  temp33.1 <- read_html(temp31[[1]]) %>% 
    html_elements('div.byline') %>% 
    html_text() %>% 
    str_remove_all(' 기자') %>% 
    tibble()
  
  temp34 <- read_html(temp31[[1]]) %>% 
    html_elements('li.article') %>% 
    html_elements('a') %>% 
    html_attr('onclick') %>% 
    tibble() %>% 
    distinct()
  
  temp34.1 <- temp34$. %>% 
    str_remove('goDetail') %>% 
    str_remove('\\(') %>% 
    str_remove('\\)') %>% 
    str_remove_all("'")
  
  temp34.2 <- paste0('https://news1.kr', temp34.1) %>% 
    tibble()
  
  temp35 <- tibble(제목 = temp32$., 기자 = temp33.1$., 시각 = temp33$., 링크 = temp34.2$.) %>% 
    relocate(시각, 기자, 링크, 제목)
  
  temp35.1 <- temp35$시각 %in% paste0(1:PERIOD, '시간전')
  
  temp35.2 <- temp35$시각 %in% paste0(1:60, '분전')
  
  if(sum(temp35.1, temp35.2) == 0) break
  
  NEWS1 <- rbind(NEWS1, temp35)
  
}

# 4. close

REMDR$close()

terminalKill(terminalList())

# 5. export

write.xlsx(x = list(INFOMAX, EBN, NEWSPIM, GLOBALECO, YHNEWS, NEWSIS, NEWS1), 
           sheetName = c('연합인포맥스(전체)', '산업경제신문(전체)', '뉴스핌(글로벌)', '글로벌이코노믹(국제)',
                         '연합뉴스(세계)', '뉴시스(국제최신)', '뉴스1(국제)'), 
           file = paste(today(), '뉴스.xlsx'), overwrite = TRUE)

# 6. summary 

temp36 <- nrow(INFOMAX) + nrow(EBN) + nrow(NEWSPIM) + nrow(GLOBALECO) + nrow(YHNEWS) + nrow(NEWSIS) + nrow(NEWS1)
temp37 <- paste0('안녕하세요 위원님, ', now() - hours(PERIOD), ' 부터 지금까지 작성된 기사 ', temp36 ,' 개를 모았습니다.')
temp38 <- paste0('RStudio를 종료하고, ', FOLDER, ' 폴더 내 [', today(), ' 뉴스.xlsx] 파일을 확인해주세요.')

print(c(temp37, temp38)) # Console 탭을 눌러주세요
