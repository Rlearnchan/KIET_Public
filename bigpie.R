# bigpie

# 1. setting

setwd('C:/Users/KIET/Desktop/bigpie') # 작업경로 설정

library(tidyverse) # 데이터 핸들링
library(rstudioapi) # 터미널 사용
library(RSelenium) # 크롬 자동화
library(rvest) # html 해석
library(openxlsx) # 엑셀 입출력

# 2. selenium

TERM_COMMAND <- 'java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-4.0.0-alpha-1.jar -port 4445'
terminalExecute(command = TERM_COMMAND) 

REMDR = remoteDriver(port = 4445, browserName = 'chrome')
REMDR$open() # 크롬 오픈

# 크롬 전체화면 및 다운로드 경로 설정(수동)

# 3-1. login

URL <- 'https://bigfinance.co.kr/login'

REMDR$navigate(URL)

TEXT_ID <- REMDR$findElement('xpath', '//*[@id="root"]/div[2]/div/form/div[1]/input')
TEXT_ID$sendKeysToElement(list('sh2@kiet.re.kr'))

TEXT_PW <- REMDR$findElement('xpath', '//*[@id="root"]/div[2]/div/form/div[2]/input')
TEXT_PW$sendKeysToElement(list('library@123'))

BUTTON_LOGIN <- REMDR$findElement('xpath', '//*[@id="root"]/div[2]/div/form/button')
BUTTON_LOGIN$clickElement()

# 3-2. loop

DATA <- tibble()

REMDR$navigate('https://bigfinance.co.kr/industry?type=recent&code=-1')

Sys.sleep(1)

temp <- REMDR$getPageSource()[[1]]

INDUSTRY <- read_html(temp) %>% 
  html_elements('li.nav__list__item') %>% 
  html_text() 

INDUSTRY[str_ends(INDUSTRY, 'N')] <- INDUSTRY[str_ends(INDUSTRY, 'N')] %>% str_sub(end = -2) # 산업

for (A in 2:length(INDUSTRY)) {
  
  BUTTON_INDUSTRY <- REMDR$findElement('xpath', paste0('//*[@id="root"]/main/section/aside/div/div/ul/li[', A, ']/span'))
  BUTTON_INDUSTRY$clickElement()
 
  Sys.sleep(1)
  
  temp <- REMDR$getPageSource()[[1]]
  
  CATEGORY <- read_html(temp) %>% 
    html_elements('li.category__list__item') %>% 
    html_elements('span.category__list__item__text') %>% 
    html_text()
  
  CATEGORY <- CATEGORY[1:(length(CATEGORY)/2)] 
  
  CATEGORY[str_ends(CATEGORY, 'N')] <- CATEGORY[str_ends(CATEGORY, 'N')] %>% str_sub(end = -2) # 분류
  
  for (B in 1:length(CATEGORY)) {
    
    ITEM <- read_html(temp) %>% 
      html_elements(xpath = paste0('//*[@id="root"]/main/section/div[4]/div[1]/div/div[2]/div/div/ul/li[', B, ']')) %>% 
      html_elements('li.category__contents__list__item') %>% 
      html_text() # 항목  
    
    ITEM[str_ends(ITEM, 'N')] <- ITEM[str_ends(ITEM, 'N')] %>% str_sub(end = -2) # 항목
    
    Sys.sleep(1)
    
    for (C in 1:length(ITEM)) {
      
      BUTTON_ITEM <- REMDR$findElement('xpath', paste0('//*[@id="root"]/main/section/div[2]/div[1]/div[2]/div/div/ul/li[', B, ']/ul/li[', C, ']'))
      BUTTON_ITEM$clickElement()
      
      Sys.sleep(1)
      
      BUTTON_DOWNLOAD <- REMDR$findElement('xpath', '//*[@id="root"]/main/section/article/div[2]/button')
      BUTTON_DOWNLOAD$clickElement()
      
      Sys.sleep(1)
      
      temp <- REMDR$getPageSource()[[1]]
      
      INFO <- read_html(temp) %>% 
        html_elements('div.industry__contents__header__info__item__text') %>% 
        html_text()
      
      LATEST <- read_html(temp) %>% 
        html_elements(xpath = '//*[@id="root"]/main/section/article/div[3]/div[1]/div[2]/div[1]/span[2]') %>% 
        html_text()
      
      SINCE <- read_html(temp) %>% 
        html_elements(xpath = '//*[@id="root"]/main/section/article/div[3]/div[1]/div[2]/div[2]/span[2]') %>% 
        html_text()
      
      META <- tibble(산업 = INDUSTRY[A], 분류 = CATEGORY[B], 항목 = ITEM[C], 
                       시작 = SINCE, 종료 = LATEST,
                       주기 = INFO[1], 단위 = INFO[2], 출처 = INFO[3], 설명 = INFO[4])
      
      DATA <- rbind(DATA, META)  
      
    }

  }
   
}

# 4. export

TODAY <- Sys.time() %>% str_sub(end = 10)

write.xlsx(DATA, paste0(TODAY, ' 데이터 정보.xlsx'))
