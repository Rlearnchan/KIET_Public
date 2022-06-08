# budgetcode

# 22.06.08 updated

# 0. what do you need

INPUT <- '산자부.xlsx' # 위원님께서 선정한 사업의 20, 21, 22년 데이터
OUTPUT <- '산자부_코드매칭.xlsx' # 수정 후 저장할 파일 이름

# 1. setting

setwd('C:/Users/KIET/Documents/GitHub/KIET_Private/gov') # 작업 경로 설정

library(tidyverse) # 데이터 핸들링
library(openxlsx) # 엑셀 입출력

# 2. code matching

DATA <- read.xlsx(INPUT) %>% tibble() # 데이터 로드

DATA.0 <- DATA %>% filter(연도 == 2020) # 20

DATA.1 <- DATA %>% filter(연도 %in% c(2021, 2022)) # 21, 22

DATA.2 <- DATA.1[DATA.1$세부사업명 %in% DATA.0$세부사업명, ] # 20, 21 (+ 22) 연속 사업

DATA.3 <- DATA.0 %>% filter(세부사업명 %in% DATA.2$세부사업명) # 해당 사업의 원류 (20)

for (i in 1:nrow(DATA)) { 
  
  for (k in 1:nrow(DATA.3)) {
    
    if(DATA[i, 14] == DATA.3[k, 14]) { # 연속 사업인 경우
      
      DATA[i, 2] <- DATA.3[k, 2] # 코드를 채워 넣는다
      
    }
    
  }
  
} 

# 3. export

write.xlsx(DATA, OUTPUT) # 엑셀 파일로 저장
