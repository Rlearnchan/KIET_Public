# blackrock

# 22.05.02 updated

# 0. what do you need

# GEO : https://www.blackrock.com/corporate/insights/blackrock-investment-institute/interactive-charts/geopolitical-risk-dashboard
# Others : https://www.blackrock.com/corporate/insights/blackrock-investment-institute/interactive-charts/macro-dashboard

LATEST <- c('2022-03-18', # Geo 
            '2022-03-27', # Trade
            '2022-04-22', # Growth
            '2022-04-22') # Inf

# 1. setting

setwd('C:/Users/KIET/Documents/GitHub/KIET_Private/blackrock') # 작업 경로 설정

library(tidyverse) # 데이터 핸들링
library(jsonlite) # JSON 파일 로드
library(lubridate) # 날짜
library(openxlsx) # 엑셀 입출력

# 2. get data

CORE <- 'https://www.blackrock.com/blk-corp-assets/images/tools/blackrock-investment-institute/'

# 2-1. geopolitical risk indicator

GEORISK <- fromJSON(paste0(CORE, 'bgri-v2.json')) %>% # GEO JSON 파일 로드
  tibble() %>% # 데이터 테이블 전환
  relocate(date) # date 열을 맨 앞으로 이동

# 2-2. trade nowcast

TRADE <- fromJSON(paste0(CORE, 'macro-dash-trade.json')) %>% # TRADE JSON 파일 로드
  tibble() # 데이터 테이블 전환

TRADE$Tracker[TRADE$Tracker %>% str_detect('null')] <- NA # 'null' 문구 NA로 대체

TRADE$`World Trade Growth`[TRADE$`World Trade Growth` %>% str_detect('null')] <- NA # 'null' 문구 NA로 대체

TRADE <- TRADE %>% mutate_at(vars(2:3), funs(as.double)) # 텍스트 없앴으니, double 클래스로 변경

# 2-3. growth gps

temp1 <- fromJSON(paste0(CORE, 'macro-dash.json')) %>% # GPS JSON 파일 로드
  tibble() # 데이터 테이블 전환

temp2 <- c('i25', 'i1', 'i34', 'i7', 'i4', 'i10', 
           'i13', 'i16', 'i31', 'i22', 'i19', 'i28') # 내부 넘버링 반영

temp3 <- c('G7', 'US', 'EMU4', 'Japan', 'Germany', 'UK', 
           'France', 'Italy', 'Spain', 'Canada', 'Australia', 'China(Composite PMI)') # 내부 넘버링 반영

temp4 <- temp1 %>% 
  select(i0, temp2) # date, GROWTH 해당 데이터만 선택

names(temp4) <- c('date', temp3) # 이름 변경

GROWTH <- temp4 # 객체 저장

# 2-4. inflation gps

temp5 <- c('i37', 'i39', 'i41', 'i43', 'i47', 'i45', 'i49') # 내부 넘버링 반영

temp6 <- c('US', 'US PCE', 'Euro area', 'UK', 'Japan', 'Canada', 'Switzerland') # 내부 넘버링 반영

temp7 <- temp1 %>% 
  select(i0, temp5) # date, INFLATION 해당 데이터만 선택

names(temp7) <- c('date', temp6) # 이름 변경

INFLATION <- temp7 # 객체 저장

# 3. adjust date

DATA <- list(GEORISK, TRADE, GROWTH, INFLATION) # 데이터 리스트 생성

for (i in seq_along(LATEST)) { # 네 가지 데이터 테이블에 대해 다음 작업 실행
  
  END <- ymd(LATEST[i]) # LATEST 데이터의 날짜를 END
  
  START <- END - weeks(nrow(DATA[[i]])-1) # OLDEST 데이터의 날짜를 START로 하는
  
  DATA[[i]] <- DATA[[i]] %>% 
    mutate(date = seq.Date(START, END, 7)) %>% # date sequence를 만들어 date 열에 덮어씌우고
    arrange(desc(date)) # 날짜 내림차순으로 정렬
  
}

# 4. export

write.xlsx(DATA, 'blackrock.xlsx', # 작업한 데이터를
           sheetName = c('Geopolitical Risk Indicator', 'Trade Nowcast', 
                         'Growth GPS', 'Inflation GPS'), # 시트 이름 설정해 저장하는데
           overwrite = TRUE) # 주기적으로 반복할 테니 덮어쓰기 기능 활성화
