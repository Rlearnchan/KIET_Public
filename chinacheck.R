# chinacheck

# 22.06.29 updated

# 0. what do you need

YEAR = 2022 # 연도
QUARTER = 2 # 분기
FILE = '파일.xlsx' # 원자료 이름
FOLDER = 'C:/Users/KIET/Desktop/오목눈이' # 경로

# 1. setting

setwd(FOLDER) # 작업 디렉토리 지정

library(tidyverse) # 데이터 핸들링
library(openxlsx) # 엑셀 입출력

# 2. data load

# 원자료 엑셀 파일의 첫 행은 먼저 지우고 로드 바람

BSI <- read.xlsx(FILE) %>% # 엑셀 파일 로드해서
  tibble() %>% # 보기 좋게 만든 뒤
  select(contains(c('아이디', 'Q'))) %>% # 회사명, 응답 결과 variable만 고르고
  rownames_to_column(var = 'NUMBER') # row numbering은 아예 새 column으로 이관

BLANK <- c(NA, 0) # NA or 0이면 error 판단 되게끔

# 3-1. 사업비율 합계 100

ERROR1 <- BSI$Q2_M2_1 + BSI$Q2_M2_2 + BSI$Q2_M2_3 != 100

# 3-2. 사업지역 판매 현황

ERROR2 <- BSI$Q2_M2_1 %in% BLANK != TRUE & BSI$Q6_M1 %in% BLANK # 중국 사업하지만 중국현황 미기재
ERROR3 <- BSI$Q2_M2_2 %in% BLANK != TRUE & BSI$Q6_M2 %in% BLANK # 한국 사업하지만 한국현황 미기재
ERROR4 <- BSI$Q2_M2_3 %in% BLANK != TRUE & BSI$Q6_M3 %in% BLANK # 제3국 사업하지만 제3국현황 미기재

ERROR5 <- BSI$Q6_M1 %in% BLANK & BSI$Q6_M2 %in% BLANK & BSI$Q6_M3 %in% BLANK # 현황 전부 미기재

# 3-3. 현황/전망 butterfly

ERROR6 <- BSI$Q6_M1 %in% BLANK + BSI$Q11_M1 %in% BLANK == 1 # 중국판매 매치 안됨
ERROR7 <- BSI$Q6_M2 %in% BLANK + BSI$Q11_M2 %in% BLANK == 1 # 한국판매 매치 안됨
ERROR8 <- BSI$Q6_M3 %in% BLANK + BSI$Q11_M3 %in% BLANK == 1 # 제3국판매 매치 안됨

ERROR9 <- BSI$Q7_M1 %in% BLANK + BSI$Q12_M1 %in% BLANK == 1 # 인건비 매치 안됨
ERROR10 <- BSI$Q7_M2 %in% BLANK + BSI$Q12_M2 %in% BLANK == 1 # 원자재구입비 매치 안됨
ERROR11 <- BSI$Q7_M3 %in% BLANK + BSI$Q12_M3 %in% BLANK == 1 # 설비투자비 매치 안됨

ERROR12 <- BSI$Q8_M1 %in% BLANK + BSI$Q13_M1 %in% BLANK == 1 # 영업환경 매치 안됨
ERROR13 <- BSI$Q8_M2 %in% BLANK + BSI$Q13_M2 %in% BLANK == 1 # 자금조달 매치 안됨
ERROR14 <- BSI$Q8_M3 %in% BLANK + BSI$Q13_M3 %in% BLANK == 1 # 제도정책 매치 안됨

# 4. export

ERROR_LIST <- cbind(NUMBER = BSI$NUMBER, NAME = BSI$아이디, 
                    ERROR1, ERROR2, ERROR3, ERROR4, ERROR5, ERROR6, ERROR7, 
                    ERROR8, ERROR9, ERROR10, ERROR11, ERROR12, ERROR13, ERROR14) %>% # 에러 판단 결과 묶어서
  as_tibble %>% # 데이터 프레임으로 만든 뒤
  filter(if_any(starts_with('ERROR'), ~ . == 'TRUE')) # 한 개라도 에러 발생한 행만 남김

FOLDER.2 <- paste0(FOLDER, '/', YEAR, '-', QUARTER, 'Q') # 연도, 분기 따라서

dir.create(FOLDER.2) # 별도 폴더를 만든 다음

setwd(FOLDER.2) # 작업 경로로 지정해

write.xlsx(ERROR_LIST, 'errorlist.xlsx') # 엑셀 파일로 출력(저장)
