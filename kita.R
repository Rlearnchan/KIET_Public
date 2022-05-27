# kita

# 22.05.27 updated

# 0. what do you need

A <- 2 # 가공단계 : 1차산품, 소비재, 자본재, 중간재, 기타

# 1. setting

setwd('C:/Users/KIET/Documents/GitHub/KIET_Private/kita') # 작업경로 설정

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

# 3-1. login

URL.1 <- 'https://stat.kita.net'

REMDR$navigate(URL.1)

BUTTON_LOGIN <- REMDR$findElement('xpath', '//*[@id="header"]/div/div[2]/ul/li[2]/a')
BUTTON_LOGIN$clickElement()

TEXT_ID <- REMDR$findElement('xpath', '//*[@id="userId"]')
TEXT_ID$sendKeysToElement(list('kietkita'))

TEXT_PW <- REMDR$findElement('xpath', '//*[@id="pwd"]')
TEXT_PW$sendKeysToElement(list('library2'))

BUTTON_PASS <- REMDR$findElement('xpath', '//*[@id="loginBtn"]')
BUTTON_PASS$clickElement()

Sys.sleep(10) # 로그인에 시간이 다소 걸려서, 10초 delay

URL.2 <- 'https://stat.kita.net/stat/kts/use/BecCtrList.screen'

REMDR$navigate(URL.2)

# 3-2. loop

DATA <- tibble() # 데이터 담을 빈 그릇

CATEGORY <- case_when(A == 1 ~ '1차산품',
                      A == 2 ~ '소비재',
                      A == 3 ~ '자본재',
                      A == 4 ~ '중간재',
                      A == 5 ~ '기타')
  
for (B in 23:1) { # 연도
  
  for (C in 1:12) { # 월
    
    for (D in 1:3) { # 페이지
      
      # 1) setting
      
      LIST_CATEGORY <- REMDR$findElement('xpath', paste0('//*[@id="contents"]/div[2]/form/fieldset/div[1]/div/select/option[', A, ']'))
      LIST_CATEGORY$clickElement() # 가공단계
      
      LIST_YEAR <- REMDR$findElement('xpath', paste0('//*[@id="contents"]/div[2]/form/fieldset/div[2]/div[1]/select/option[', B, ']'))
      LIST_YEAR$clickElement() # 연도
      
      LIST_MONTH <- REMDR$findElement('xpath', paste0('//*[@id="contents"]/div[2]/form/fieldset/div[2]/div[2]/select/option[', C, ']'))
      LIST_MONTH$clickElement() # 월
      
      LIST_CUMMULATE <- REMDR$findElement('xpath', '//*[@id="contents"]/div[2]/form/fieldset/div[2]/div[3]/select/option[1]')
      LIST_CUMMULATE$clickElement() # 당월
      
      LIST_VIEW <- REMDR$findElement('xpath', '//*[@id="listCount"]/option[3]')
      LIST_VIEW$clickElement() # 100개씩 보기
      
      BUTTON_SEARCH <- REMDR$findElement('xpath', '//*[@id="contents"]/div[2]/form/fieldset/div[3]/a/img')
      BUTTON_SEARCH$clickElement() # 조회
      
      Sys.sleep(5) # 안정성 높이려 5초 delay
      
      temp1 <- REMDR$getPageSource()[[1]] # 페이지 소스 가져오기
      
      # 2) get data
      
      NAME <- read_html(temp1) %>% # html을 읽어서
        html_elements(paste0('td.GMClassReadOnly', # column 선택 (f12 눌러서 체크)
                             '.GMEllipsis',
                             '.GMAlignLeft',
                             '.GMText',
                             '.GMCell',
                             '.IBSheetFont0',
                             '.HideCol0C6')) %>% 
        html_text() # 텍스트 추출
      
      if(D == 1) { NAME <- append(NAME, '총계', 0) } # '총계'가 공란으로 나와 추가 기입
      
      EXPORT <- read_html(temp1) %>% 
        html_elements(paste0('td.GMClassReadOnly',
                             '.GMWrap0',
                             '.GMAlignRight',
                             '.GMInt',
                             '.GMCell',
                             '.IBSheetFont0',
                             '.HideCol0C12')) %>% 
        html_text()
      
      EXPORT_RATE <- read_html(temp1) %>% 
        html_elements(paste0('td.GMClassReadOnly',
                             '.GMWrap0',
                             '.GMAlignRight',
                             '.GMFloat',
                             '.GMCell',
                             '.IBSheetFont0',
                             '.HideCol0C13')) %>% 
        html_text()
      
      IMPORT <- read_html(temp1) %>% 
        html_elements(paste0('td.GMClassReadOnly',
                             '.GMWrap0',
                             '.GMAlignRight',
                             '.GMInt',
                             '.GMCell',
                             '.IBSheetFont0',
                             '.HideCol0C14')) %>% 
        html_text()
      
      IMPORT_RATE <- read_html(temp1) %>% 
        html_elements(paste0('td.GMClassReadOnly',
                             '.GMWrap0',
                             '.GMAlignRight',
                             '.GMFloat',
                             '.GMCell',
                             '.IBSheetFont0',
                             '.HideCol0C15')) %>% 
        html_text()
      
      BALANCE <- read_html(temp1) %>% 
        html_elements(paste0('td.GMClassReadOnly',
                             '.GMWrap0',
                             '.GMAlignRight',
                             '.GMInt',
                             '.GMCell',
                             '.IBSheetFont0',
                             '.HideCol0C16')) %>% 
        html_text()
      
      temp2 <- tryCatch(tibble(YEAR = 2023-B, MONTH = C, CATEGORY,
                               NAME, EXPORT, EXPORT_RATE, IMPORT, IMPORT_RATE, BALANCE),
                        error = function(e) tibble(NULL)) # 데이터 프레임 만들되 오류 무시
      
      DATA <- rbind(temp2, DATA) # 기존 데이터 slot에 쌓아 올림
      
      # 3) next page
      
      BUTTON_NEXT <- tryCatch(REMDR$findElement('xpath', paste0('//*[@id="pageArea"]/span/a[', D, ']')),
                              error = function(e) NULL,
                              warning = function(e) NULL) # next page 버튼 찾되, 없으면 패스
      
      tryCatch(BUTTON_NEXT$clickElement(), error = function(e) NULL) # next page 전환
      
    }
    
  }
  
}

# 4. refine

RESULT <- DATA %>% # 모은 데이터를
  arrange(YEAR, MONTH, NAME) %>% # 연도, 월, 국가명 순으로 정렬
  mutate_at(vars(EXPORT:BALANCE), funs(str_remove_all(., ','))) %>% # 숫자 쉼표 없애고
  mutate_at(vars(EXPORT:BALANCE), funs(as.double)) # 문자 -> 숫자 클래스로 변경

# 5. export
  
write.xlsx(RESULT, paste0('kita_', CATEGORY,'.xlsx')) # 엑셀로 저장
