# dobby

# 22.04.19 updated

# 0. what do you need

FOLDER = paste0('C:/Users/', Sys.info()['user'], '/Documents/GitHub/KIET/dobby')

WHEN <- '17:45:00'
ID <- '21032'
PW <- '21032961228'
SHUTDOWN <- 'YES'

# 1. setting

setwd(FOLDER)

library(tidyverse)
library(rstudioapi)
library(RSelenium)
library(rvest)
library(lubridate)

# 2. selenium

TERM_COMMAND <- 'java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-4.0.0-alpha-1.jar -port 4445'
terminalExecute(command = TERM_COMMAND)
REMDR = remoteDriver(port = 4445, browserName = 'chrome')

REMDR$open()

# 3. commute check

for (i in 1:100) {
  
  # 3-1. time to go
  
  NOW <- now(tzone = 'Asia/Seoul')
  TODAY <- today(tzone = 'Asia/Seoul')
  GOHOME <- paste0(TODAY, ' ', WHEN) %>% ymd_hms(tz = 'Asia/Seoul')
  
  if(GOHOME > NOW){
    
    REMDR$navigate('https://www.kiet.re.kr/kiet_web/main/')
    
    print(paste0('자동퇴근 프로그램이 작동 중입니다.', ' (현재 : ', i, ' 회차)'))
    
    print('퇴근까지 남은 시간을 알려드립니다.')
    
    print(GOHOME - NOW)
    
  }
  
  if(GOHOME < NOW){
    
    # 3-2. login
    
    REMDR$navigate('https://ep.kiet.re.kr/index.do')
    
    BUTTON_LOGIN <- REMDR$findElement('xpath', '//*[@id="f_login"]/ul/li[3]')
    TEXT_ID <- REMDR$findElement('xpath', '//*[@id="loginId"]')
    TEXT_PW <- REMDR$findElement('xpath', '//*[@id="pwd"]')
    
    TEXT_ID$sendKeysToElement(list(ID))
    TEXT_PW$sendKeysToElement(list(PW))
    BUTTON_LOGIN$clickElement()
    
    # 3-3. leave
    
    temp <- REMDR$findElement('name', 'mainFrame')
    
    REMDR$switchToFrame(temp)
    
    BUTTON_LEAVE <- REMDR$findElement('xpath', '//*[@id="left"]/div[1]/a[2]')
    
    BUTTON_LEAVE$clickElement()
    
    # 3-4. turn off
    
    ifelse(SHUTDOWN == 'YES', system('shutdown -s'), '전기를 아낍시다.')
    
    # 3-5. quit
    
    q()
    
  }
  
  Sys.sleep(300 + rnorm(n = 1, mean = 10, sd = 2))
  
}
