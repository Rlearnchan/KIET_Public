# dobby

# 22.05.01 updated

# 0. what do you need

WHEN <- '17:45:00' # 17시 45분 이후 체크
ID <- '210##' # 포털 아이디
PW <- '210########' # 포털 비밀번호 
SHUTDOWN <- 'YES' # 퇴근체크 후, 컴퓨터 종료할 지 선택

# 1. setting

setwd('C:/Users/KIET/Documents/GitHub/KIET_Private/dobby') # 작업 경로 설정

library(tidyverse) # 데이터 핸들링
library(rstudioapi) # 터미널 사용
library(RSelenium) # 크롬 자동화
library(rvest) # html 해석
library(lubridate) # 날짜

# 2. selenium

TERM_COMMAND <- 'java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-4.0.0-alpha-1.jar -port 4445'
terminalExecute(command = TERM_COMMAND)
REMDR = remoteDriver(port = 4445, browserName = 'chrome')

REMDR$open() # 크롬 오픈

# 3. commute check

for (i in 1:100) { # 아래 작업을 100번 반복, 5분 마다 시행
  
  # 3-1. time to go
  
  NOW <- now(tzone = 'Asia/Seoul') # 현재 시각
  TODAY <- today(tzone = 'Asia/Seoul') # 오늘 날짜
  GOHOME <- paste0(TODAY, ' ', WHEN) %>% ymd_hms(tz = 'Asia/Seoul') # 집에 갈 시각, dttm 클래스로 변경
  
  if(GOHOME > NOW){ # 퇴근하기 전이면
    
    REMDR$navigate('https://www.kiet.re.kr/kiet_web/main/') # 산연 홈페이지에 접속하고
    
    print(paste0('자동퇴근 프로그램이 작동 중입니다.', ' (현재 : ', i, ' 회차)')) # 작동 중임을 Console 창에 띄움
    
    print('퇴근까지 남은 시간을 알려드립니다.') # 그냥 있으면 심심하니까
    
    print(GOHOME - NOW) # 남은 시간도 계산해 출력
    
  }
  
  if(GOHOME < NOW){ # 퇴근할 때가 되면
    
    # 3-2. login
    
    REMDR$navigate('https://ep.kiet.re.kr/index.do') # 업무 포털 접속해서
    
    BUTTON_LOGIN <- REMDR$findElement('xpath', '//*[@id="f_login"]/ul/li[3]') # 로그인 버튼
    TEXT_ID <- REMDR$findElement('xpath', '//*[@id="loginId"]') # 아이디 입력창
    TEXT_PW <- REMDR$findElement('xpath', '//*[@id="pwd"]') # 패스워드 입력창을 찾아내고
    
    TEXT_ID$sendKeysToElement(list(ID)) # 아이디 입력
    TEXT_PW$sendKeysToElement(list(PW)) # 패스워드 입력
    BUTTON_LOGIN$clickElement() # 로그인 버튼 클릭
    
    # 3-3. leave
    
    temp <- REMDR$findElement('name', 'mainFrame') # 업무포털이 여러 개 frame으로 구성, 원하는 파트를 지정
    
    REMDR$switchToFrame(temp) # 프레임 전환
    
    BUTTON_LEAVE <- REMDR$findElement('xpath', '//*[@id="left"]/div[1]/a[2]') # 퇴근 버튼 찾아내서
    
    BUTTON_LEAVE$clickElement() # 퇴근 버튼 클릭
    
    # 3-4. turn off
    
    ifelse(SHUTDOWN == 'YES', system('shutdown -s'), '전기를 아낍시다.') # 컴퓨터 끄는 게 아니면 전기 아낌이 출력
    
    # 3-5. quit
    
    q() # R 종료
    
  }
  
  Sys.sleep(300 + rnorm(n = 1, mean = 10, sd = 2)) # 5분 + 10초 내외 동안 delay
  
}
