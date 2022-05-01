# psi

# 22.05.01 updated

INTERN <- ifelse(Sys.info()['user'] == 'fragr', # 랩탑에서 사용한다면
                 '/Dropbox/GitHub/KIET_Public', # 랩탑 경로
                 '/KIET/Documents/GitHub/KIET_Public') # 아니면 회사 경로

# 0. what do you need

FOLDER = paste0('C:/Users/', Sys.info()['user'], INTERN) # 본인이 작업할 폴더


YEAR = 2022
MONTH = 3
FILE = '2022년3월_누적시계열_PSI_작성용(잠정).xlsx' # 최신 버전 누적시계열 파일

# 1. setting

setwd(FOLDER)

library(tidyverse) # 데이터 핸들링 패키지
library(readxl) # 엑셀 로드 패키지
library(openxlsx) # 엑셀 출력 패키지

ROUND <- function(x, digits = 0) {
  
  posneg = sign(x)
  
  z = abs(x)*10^digits
  z = z + 0.5 + sqrt(.Machine$double.eps)
  z = trunc(z)
  z = z/10^digits
  
  z*posneg
  
} # 기본 function은 round(0.5) = 0 만들어서, ROUND(0.5) = 1 되는 사용자 함수 생성

# 2. data load

PSI_SIMPLE <- read_xlsx(FILE, '종합(단순평균)', na = c('', NA)) # 누적시계열의 1번 시트
PSI_WEIGHTED <- read_xlsx(FILE, '종합(가중평균)', na = c('', NA)) # 누적시계열의 2번 시트

PSI_SIMPLE_CUT <- PSI_SIMPLE %>% filter(연도 == YEAR, 월 == MONTH) # 필요 시점 데이터만 선택
PSI_WEIGHTED_CUT <- PSI_WEIGHTED %>% filter(연도 == YEAR, 월 == MONTH) # 필요 시점 데이터만 선택

# 3. make table

# 3-1. 업종별 패널 구성(p.2)

temp1 <- PSI_SIMPLE_CUT %>% # 2022년 2월 단순평균 데이터에서 다음 작업을 한 뒤 temp1 임시 객체로 저장
  select(구분, 응답수) %>% # 구분, 응답수 column만 골라서
  mutate(`응답자 구성비(%)` = ROUND(응답수 / PSI_SIMPLE_CUT$응답수[1] * 100, digits = 1)) # 소수점 한 자리로 구성비 계산하고 변수 생성

APPENDIX.1 <- temp1[c(9, 8, 5, 7, 6, 11, 12, 10, 15, 14, 13, 16, 17, 18), ] %>% # 부표 양식대로 산업 순서 바꾸고
  select(1, 3) # 구분, 응답자 구성비만 저장

# 3-2. 기상도(p.3-4)

temp2 <- PSI_SIMPLE_CUT %>% # 단순평균 데이터에서
  select(경기현황, 시장판매현황, 수출현황, 생산수준현황, 투자액현황, 채산성현황) %>% # 항목(변수)을 고른 뒤
  ROUND() %>% # 반올림 해주고
  mutate(구분 = PSI_SIMPLE_CUT$구분) %>% # 반올림 하느라 빼두었던 character variable 다시 넣고
  relocate(구분) # 순서도 맨 앞으로 조정

APPENDIX.2 <- temp2[c(1, 9, 8, 5, 7, 6, 11, 12, 10, 15, 14, 13, 16, 2, 3, 4), ] # 부표 양식 맞춰서 저장

temp3 <- PSI_SIMPLE_CUT %>% 
  select(경기전망, 시장판매전망, 수출전망, 생산수준전망, 투자액전망, 채산성전망) %>% 
  ROUND() %>% 
  mutate(구분 = PSI_SIMPLE_CUT$구분) %>% 
  relocate(구분)

APPENDIX.3 <- temp3[c(1, 9, 8, 5, 7, 6, 11, 12, 10, 15, 14, 13, 16, 2, 3, 4), ] # APPENDIX.2와 같은 방식으로 전망 파트 작업

# 3-3. 제조업 및 부문별 통계(p.5-12)

temp4 <- PSI_SIMPLE_CUT %>% # 단순평균 데이터에서
  select(-c(1:4)) %>% # 1~4번째 column(연도, 월, 구분, 응답수) 제외하고, 즉 psi 값만 대상으로
  ROUND() %>% # 반올림 해주고
  mutate(구분 = PSI_SIMPLE_CUT$구분) %>% # 빼두었던 산업 구분 넣고
  relocate(구분) %>% # 맨 앞으로 옮겨준 다음
  filter(구분 %in% c('00_전체', '01_ICT', '02_장비', '03_소재')) %>% # 전체, ICT, 장비, 소재 행만 선택
  select(구분, starts_with(c('경기', '시장', '수출', '생산', '재고', '투자', '채산성', '제품단가'))) # 산업 구분과 부표 파트인 열만 선택 

temp4$재고수준현황 <- abs(temp4$재고수준현황 - 200) # 재고수준은 200 빼고 절대값 취해서 계산
temp4$재고수준전망 <- abs(temp4$재고수준전망 - 200)

temp5 <- PSI_WEIGHTED_CUT %>% # 가중평균 데이터에서도 비슷한 작업을 하는데
  select(-c(1:4)) %>% 
  ROUND() %>% 
  mutate(구분 = PSI_SIMPLE_CUT$구분) %>% 
  relocate(구분) %>% 
  filter(구분 %in% c('00_전체')) %>% # 제조업(전체)만 필요하니까 하나 선택
  select(구분, starts_with(c('경기', '시장', '수출', '생산', '재고', '투자', '채산성', '제품단가')))

temp5$재고수준현황 <- abs(temp5$재고수준현황 - 200)
temp5$재고수준전망 <- abs(temp5$재고수준전망 - 200)

temp5[1, 1] <- '00_전체_가중' # 이름 같으면 헷갈리니까 가중지수는 따로 네이밍

temp6 <- rbind(temp4, temp5) # 단순평균, 가중평균 데이터에서 뽑아낸 4개, 1개 열을 묶고

temp7 <- temp6[c(1, 5, 2, 3, 4), ] %>% # 열 순서 조정한 다음
  t() %>% # 행열 뒤집고 (부표 스타일 보니, 가져다 붙이려면 뒤집는 게 좋아보임)
  as.data.frame() %>% # 데이터 프레임 형식으로 바꾸고 (matrix와 비슷)
  rownames_to_column() %>% # rowname으로 내려온 파트 이름을 아예 column 으로 만들고
  tibble() %>% # 조금 더 정제된 데이터 프레임 형식 전환
  filter(rowname != '구분') # 첫 줄은 거추장스러워서 제거

names(temp7) <- c('파트', '단순지수', '가중지수', 'ICT부문', '기계부문', '소재부문') # 네이밍 수정

APPENDIX.4 <- temp7 %>% 
  mutate_at(vars(단순지수:소재부문), as.double) # 변환하면서 character로 입력된 숫자값을 number class로 바꾸고 저장

# 3-4. 세부 업종별 조사 통계(p.13-20)

temp8 <- PSI_SIMPLE_CUT %>% # 대충 비슷하니까 이하는 안써도 되겠지?
  select(-c(1:4)) %>% 
  ROUND() %>% 
  mutate(구분 = PSI_SIMPLE_CUT$구분) %>% 
  relocate(구분) %>%
  filter(구분 %in% c('08_반도체', '07_디스플레이', '06_핸드폰', '05_가전', '10_자동차',
                   '11_조선', '09_기계', '14_화학', '13_철강', '12_섬유', '15_바이오헬스')) %>% 
  select(구분, starts_with(c('경기', '시장', '수출', '생산', '재고', '투자', '채산성', '제품단가')))

temp8$재고수준현황 <- abs(temp8$재고수준현황 - 200)
temp8$재고수준전망 <- abs(temp8$재고수준전망 - 200)

temp9 <- temp8 %>%
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column() %>% 
  tibble() 

temp10 <- temp9[-1, c(1, 5, 4, 3, 2, 7, 8, 6, 11, 10, 9, 12)]

names(temp10) <- c('파트', '08_반도체', '07_디스플레이', '06_핸드폰', '05_가전', '10_자동차',
                   '11_조선', '09_기계', '14_화학', '13_철강', '12_섬유', '15_바이오헬스')

APPENDIX.5 <- temp10 %>% 
  mutate_at(vars(`08_반도체`:`15_바이오헬스`), as.double)# 세부 업종별 조사 통계

# 5. export

FOLDER.2 <- paste0(FOLDER, '/', YEAR, '-', MONTH, 'M')

dir.create(FOLDER.2)

setwd(FOLDER.2)

write.xlsx(x = list(APPENDIX.1, APPENDIX.2, APPENDIX.3, APPENDIX.4, APPENDIX.5),
           sheetName = c('업종별 패널 구성(p.2)', '현황 PSI(p.3)', '전망 PSI(p.4)',
                         '제조업 및 부문별 통계(p.5-12)',
                         '세부 업종별 조사 통계(p.13-20)'),
           file = paste0(YEAR, '-', MONTH, 'M PSI 보도자료용 부표.xlsx'))
