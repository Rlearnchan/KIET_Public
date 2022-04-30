# kosis

# 22.04.15 updated

# 0. what do you need

FOLDER = paste0('C:/Users/', Sys.info()['user'], '/Documents/GitHub/KIET_831/kosis')

# 1. setting

setwd(FOLDER)

library(tidyverse)
library(jsonlite)
library(openxlsx)
library(lubridate)

BASE <- paste0('https://kosis.kr/openapi/statisticsData.do?method=getList', # 요청
               '&apiKey=OTYwMWVjNTNmMmUxMjAyMGI5MjdkMjEwM2E4NTQ1OGQ=', # 인증키
               '&format=json&jsonVD=Y', # 포맷 : JSON
               '&userStatsId=bhc5754/') # 방식 : 사용자가 기등록한 자료 로드

# 2. 광업제조업동향조사

# 2-1. 생산출하재고

CORE_생산출하재고 <- c('20220413144648', '20220413170357', '20220414092428') # 항목별 코드 (사용자 URL)

NUMBER_생산출하재고 <- 1:84

DATA_생산출하재고 <- tibble()

for (k in seq_along(CORE_생산출하재고)) {
  
  temp1 <- tibble()
  
  for (i in seq_along(NUMBER_생산출하재고)) {
    
    URL_생산출하재고 <- paste0(BASE,
                               '101/', # 통계청
                               'DT_1F01501/', # 시도/산업별 광공업생산지수(2015=100)
                               '2/', # 시계열
                               '1/', # 간격 : 1
                               CORE_생산출하재고[k], '_', NUMBER_생산출하재고[i], # URL 나열
                               '&prdSe=', 'M', # 주기 : Month
                               '&newEstPrdCnt=', '1') # 최근 1개 자료
    
    temp2 <- tryCatch(fromJSON(URL_생산출하재고) %>% 
                      tibble() %>% 
                      mutate(번호 = i) %>% 
                      select(번호, TBL_NM, ITM_ID, ITM_NM, PRD_DE, C1, C1_NM, C2, C2_NM, DT), # 필요 column 선택
                      error = function(e) tibble(NULL)) # 오류(데이터 부재) 발생하면 스킵
    
    temp1 <- rbind(temp2, temp1) # stacking
    
  }
  
  temp3 <- temp1 %>% 
    arrange(nchar(C2), C2) %>% # 분류값 순으로 정렬  
    mutate_at(vars(DT), as.double) # 수치값 class 숫자로 변경
  
  DATA_생산출하재고 <- rbind(temp3, DATA_생산출하재고) # stacking
  
}

temp4 <- DATA_생산출하재고 %>% split(as.factor(.$ITM_ID)) # 항목별 data frame 분리

temp5 <- DATA_생산출하재고$ITM_NM %>% unique() # 항목 이름

write.xlsx(temp4, sheetName = temp5, paste0(today(tzone = 'Asia/Seoul'), ' 생산출하재고.xlsx'))

# 2-2. 생산능력가동률

# 3. 서비스업동향조사
