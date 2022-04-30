# bsi_chinacheck

# 22.04.15 updated

# 0. what do you need

FOLDER = paste0('C:/Users/', Sys.info()['user'], '/Documents/GitHub/KIET_831/bsi_chinacheck')

YEAR = 2022
QUARTER = 1
FILE = '중국 BSI 1분기 원자료 확인_raw data_20220329_17h13m(검증용).xlsx'

# 1. setting

setwd(FOLDER) # 작업 디렉토리 지정

library(tidyverse) # 데이터 핸들링
library(readxl) # 엑셀 로드
library(writexl) # 엑셀 출력

# 2. data load

# 원자료 엑셀 파일의 첫 행은 먼저 지우고 로드 바람

BSI <- read_xlsx(FILE) %>% # 엑셀 파일 읽어와서
  mutate(NAME = `이름...8`) %>% # 회사명(8번째 column) 변수명을 NAME으로 변경 
  select(contains(c('NAME', 'Q'))) %>% # 회사명, 응답 결과 variable만 고르고
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

ERROR_LIST <- cbind(NUMBER = BSI$NUMBER, NAME = BSI$NAME, 
                    ERROR1, ERROR2, ERROR3, ERROR4, ERROR5, ERROR6, ERROR7, 
                    ERROR8, ERROR9, ERROR10, ERROR11, ERROR12, ERROR13, ERROR14) %>% # 에러 판단 결과 묶어서
  as_tibble %>% # 데이터 프레임으로 만든 뒤
  filter(if_any(starts_with('ERROR'), ~ . == 'TRUE')) # 한 개라도 에러 발생한 행만 남김

FOLDER.2 <- paste0(FOLDER, '/', YEAR, '-', QUARTER, 'Q')

dir.create(FOLDER.2)

setwd(FOLDER.2)

write_xlsx(ERROR_LIST, 'errorlist.xlsx') # 엑셀 파일로 출력(저장)
