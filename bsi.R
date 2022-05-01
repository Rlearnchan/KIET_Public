# bsi

# 22.05.01 updated

INTERN <- ifelse(Sys.info()['user'] == 'fragr', # 랩탑에서 사용한다면
                 '/Dropbox/GitHub/KIET_Public', # 랩탑 경로
                 '/KIET/Documents/GitHub/KIET_Public') # 아니면 회사 경로

# 0. what do you need

FOLDER = paste0('C:/Users/', Sys.info()['user'], INTERN) # 본인이 작업할 폴더

YEAR = 2022 # 연도
QUARTER = 1 # 분기
FILE = '케이스탯(2022.03) - 제조업 경기조사 및 패널기업 관리 결과표(2022년 1분기)_220404.xlsx' # 원자료 이름

# 1. setting

setwd(FOLDER) # 작업 경로 설정

library(tidyverse) # 데이터 핸들링
library(readxl) # 엑셀 로드
library(openxlsx) # 엑셀 출력

ROUND <- function(x, digits = 0) {
  
  posneg = sign(x)
  
  z = abs(x)*10^digits
  z = z + 0.5 + sqrt(.Machine$double.eps)
  z = trunc(z)
  z = z/10^digits
  
  z*posneg
  
} # 기본 function은 round(0.5) = 0 만들어서, ROUND(0.5) = 1 되는 사용자 함수 생성

# 다소 복잡하고, 추후 개선 여지가 많아 코드 설명을 상세히 적지 않음

# 2. data load

BSI_SECTOR <- read_excel(FILE, sheet = '업종별 BSI')

temp1 <- read_excel(FILE, sheet = '유형별 BSI')

colnames(temp1) <- temp1[1, ]

BSI_TYPE <- temp1 %>% 
  slice(-1) %>%
  mutate_at(vars(ICT:수출기업), as.double)

temp2 <- read_excel(FILE, sheet = '유형별 개별지수')

colnames(temp2) <- temp2[1, ]

BSI_DETAIL <- temp2 %>% 
  slice(-1) %>% 
  mutate_at(vars(반도체:이차전지), as.double)

BSI_REGION <- read_excel(FILE, sheet = '지역별 BSI')

# 3. 보도자료용 부표

# 3-1. 응답 업체 구성(p.2)

temp3 <- BSI_SECTOR %>% filter(산업 == '응답기업수')

temp4 <- BSI_TYPE %>% filter(산업 == '응답기업수')

ORDER <- c('산업', '반도체', '디스플레이', '무선통신기기', '가전',
           '자동차', '조선', '일반기계',
           '정유', '화학', '철강', '섬유',
           '바이오/헬스', '이차전지',
           '제조업 전체',
           'ICT', '기계', '소재', '신산업',
           '대기업', '중소기업', '내수기업', '수출기업') # 부표 내 산업 순서

APPENDIX.1 <- right_join(temp3, temp4) %>% 
  relocate(all_of(ORDER)) %>% 
  pivot_longer(cols = 2:23) %>% 
  select(-1) %>% 
  mutate(비중 = ROUND(value / 1000 * 100, digits = 1)) %>% 
  select(name, 비중)

# 3-2. 기상도(p.3-4)

temp5 <- BSI_SECTOR %>% slice(3:14)

temp6 <- BSI_TYPE %>% slice(2:13)

temp7 <- right_join(temp5, temp6) %>% 
  relocate(all_of(ORDER)) %>% 
  relocate('제조업 전체', .after = '산업') %>% 
  t() %>% 
  as.data.frame() %>%
  rownames_to_column() %>% 
  tibble()

colnames(temp7) <- temp7[1, ]

BSI_CUT.1 <- temp7 %>% 
  slice(-1) %>% 
  mutate_at(vars(시황:`자금사정@1`), as.double) %>% 
  mutate_at(vars(시황:`자금사정@1`), ROUND) # longer 현황

APPENDIX.2 <- BSI_CUT.1 %>% 
  select('산업', '매출액@1', '국내시장출하@1', '수출@1', 
         '경상이익@1', '설비투자@1', '고용@1')

temp8 <- BSI_SECTOR %>% slice(15:26)

temp9 <- BSI_TYPE %>% slice(14:25)

temp10 <- right_join(temp8, temp9) %>% 
  relocate(all_of(ORDER)) %>% 
  relocate('제조업 전체', .after = '산업') %>% 
  t() %>% 
  as.data.frame() %>%
  rownames_to_column() %>% 
  tibble()

colnames(temp10) <- temp10[1, ]

BSI_CUT.2 <- temp10 %>% 
  slice(-1) %>% 
  mutate_at(vars(`시황전망@2`:`자금사정전망@2`), as.double) %>% 
  mutate_at(vars(`시황전망@2`:`자금사정전망@2`), ROUND) # longer 전망

APPENDIX.3 <- BSI_CUT.2 %>% 
  select('산업', '매출액전망@2', '국내시장출하전망@2', '수출전망@2', 
         '경상이익전망@2', '설비투자전망@2', '고용전망@2')

# 3-3. 제조업 전체 및 분류별 통계(p.5-16)

temp11 <- BSI_CUT.1 %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column() %>% 
  tibble

colnames(temp11) <- temp11[1, ]

BSI_CUT.3 <- temp11 %>% 
  slice(-1) %>% 
  mutate_at(vars(`제조업 전체`:수출기업), as.double) %>% 
  rename(구분 = 산업) # wider 현황

temp12 <- BSI_CUT.3 %>% 
  select('구분', '제조업 전체', 
         'ICT', '기계', '소재', '신산업', 
         '대기업', '중소기업')

temp13 <- BSI_CUT.2 %>% 
  t() %>% 
  as.data.frame() %>% 
  rownames_to_column() %>% 
  tibble

colnames(temp13) <- temp13[1, ]

BSI_CUT.4 <- temp13 %>% 
  slice(-1) %>% 
  mutate_at(vars(`제조업 전체`:수출기업), as.double) %>% 
  rename(구분 = 산업) # wider 전망

temp14 <- BSI_CUT.4 %>% 
  select('구분', '제조업 전체', 
         'ICT', '기계', '소재', '신산업', 
         '대기업', '중소기업')

APPENDIX.4 <- rbind(temp12, temp14)

# 3-4. 세부 업종별 조사 통계(p.17-28)

temp15 <- BSI_CUT.3 %>% select('구분', ORDER[2:14])

temp16 <- BSI_CUT.4 %>% select('구분', ORDER[2:14])

APPENDIX.5 <- rbind(temp15, temp16)

# 4. 주관식 답변(산업부 제공)

BSI_RAWDATA <- read_xlsx(FILE, sheet = 7)

temp17 <- BSI_RAWDATA %>% 
  select(COM, JCODE, JCODE1, Q5_M1, Q5_M1_ET, Q8_M1, Q8_M1_ET) %>% 
  mutate(업종 = case_when(JCODE == 1 ~ '반도체', 
                          JCODE == 2 ~ '디스플레이',
                          JCODE == 3 ~ '가전',
                          JCODE == 4 ~ '무선통신기기',
                          JCODE == 5 ~ '정유',
                          JCODE == 6 ~ '화학',
                          JCODE == 7 ~ '철강',
                          JCODE == 8 ~ '섬유',
                          JCODE == 9 ~ '일반기계',
                          JCODE == 10 ~ '자동차',
                          JCODE == 11 ~ '조선', 
                          JCODE == 12 ~ '바이오/헬스',
                          JCODE == 13 ~ '이차전지')) %>% 
  mutate(유형 = case_when(JCODE1 == 1 ~ 'ICT',
                          JCODE1 == 2 ~ '소재',
                          JCODE1 == 3 ~ '기계',
                          JCODE1 == 4 ~ '신산업')) %>%
  arrange(JCODE)

# 4-1. 매출액(전망) 사유

COMMENT_BAD <- tibble()

for (i in 1:13) {
  
  temp18 <- temp17 %>% 
    filter(JCODE == i & Q5_M1 %in% 1:3) %>% 
    select(JCODE, 업종, JCODE1, 유형, Q5_M1_ET)
  
  COMMENT_BAD <- rbind(COMMENT_BAD, temp18)
  
}

COMMENT_SOSO <- tibble()

for (i in 1:13) {
  
  temp19 <- temp17 %>% 
    filter(JCODE == i & Q5_M1 %in% 4) %>% 
    select(JCODE, 업종, JCODE1, 유형, Q5_M1_ET)
  
  COMMENT_SOSO <- rbind(COMMENT_SOSO, temp19)
  
}

COMMENT_GOOD <- tibble()

for (i in 1:13) {
  
  temp20 <- temp17 %>% 
    filter(JCODE == i & Q5_M1 %in% 5:7) %>% 
    select(JCODE, 업종, JCODE1, 유형, Q5_M1_ET)
  
  COMMENT_GOOD <- rbind(COMMENT_GOOD, temp20)
  
}

colnames(COMMENT_BAD)[5] <- '부정'
colnames(COMMENT_SOSO)[5] <- '불변'
colnames(COMMENT_GOOD)[5] <- '긍정'

COMMENT_BAD.1 <- COMMENT_BAD %>% 
  select(유형, 업종, 부정) %>%
  arrange(유형, 업종, 부정) # 매출액 부정 사유

COMMENT_SOSO.1 <- COMMENT_SOSO %>% 
  select(유형, 업종, 불변) %>% 
  arrange(유형, 업종, 불변)

COMMENT_GOOD.1 <- COMMENT_GOOD %>%
  select(유형, 업종, 긍정) %>%
  arrange(유형, 업종, 긍정) # 매출액 긍정 사유

# 4-2. 매출전망 사유

COMMENT_BAD <- tibble()

for (i in 1:13) {
  
  temp18 <- temp17 %>% 
    filter(JCODE == i & Q8_M1 %in% 1:3) %>% 
    select(JCODE, 업종, JCODE1, 유형, Q8_M1_ET)
  
  COMMENT_BAD <- rbind(COMMENT_BAD, temp18)
  
}

COMMENT_SOSO <- tibble()

for (i in 1:13) {
  
  temp19 <- temp17 %>% 
    filter(JCODE == i & Q8_M1 %in% 4) %>% 
    select(JCODE, 업종, JCODE1, 유형, Q8_M1_ET)
  
  COMMENT_SOSO <- rbind(COMMENT_SOSO, temp19)
  
}

COMMENT_GOOD <- tibble()

for (i in 1:13) {
  
  temp20 <- temp17 %>% 
    filter(JCODE == i & Q8_M1 %in% 5:7) %>% 
    select(JCODE, 업종, JCODE1, 유형, Q8_M1_ET)
  
  COMMENT_GOOD <- rbind(COMMENT_GOOD, temp20)
  
}

colnames(COMMENT_BAD)[5] <- '부정'
colnames(COMMENT_SOSO)[5] <- '불변'
colnames(COMMENT_GOOD)[5] <- '긍정'

COMMENT_BAD.2 <- COMMENT_BAD %>% 
  select(유형, 업종, 부정) %>%
  arrange(유형, 업종, 부정) # 매출전망 부정 사유

COMMENT_SOSO.2 <- COMMENT_SOSO %>% 
  select(유형, 업종, 불변) %>% 
  arrange(유형, 업종, 불변)

COMMENT_GOOD.2 <- COMMENT_GOOD %>%
  select(유형, 업종, 긍정) %>%
  arrange(유형, 업종, 긍정) # 매출전망 긍정 사유

rm(list = c('COMMENT_BAD', 'COMMENT_SOSO', 'COMMENT_GOOD'))

COMMENT_BAD.1$부정 <- COMMENT_BAD.1$부정 %>% str_replace_all('\n', '')
COMMENT_SOSO.1$불변 <- COMMENT_SOSO.1$불변 %>% str_replace_all('\n', '')
COMMENT_GOOD.1$긍정 <- COMMENT_GOOD.1$긍정 %>% str_replace_all('\n', '')
COMMENT_BAD.2$부정 <- COMMENT_BAD.2$부정 %>% str_replace_all('\n', '')
COMMENT_SOSO.2$불변 <- COMMENT_SOSO.2$불변 %>% str_replace_all('\n', '')
COMMENT_GOOD.2$긍정 <- COMMENT_GOOD.2$긍정 %>% str_replace_all('\n', '')

# 5. 보고서용 부표

# 5-1. 업종 BSI (내수, 수출기업만 추가)

APPENDIX.TYPE <- rbind(
  
  BSI_CUT.3 %>% 
  select('구분', '제조업 전체', 
         'ICT', '기계', '소재', '신산업', 
         '대기업', '중소기업',
         '내수기업', '수출기업'),
  
  BSI_CUT.4 %>% 
    select('구분', '제조업 전체', 
           'ICT', '기계', '소재', '신산업', 
           '대기업', '중소기업',
           '내수기업', '수출기업')
  
  ) # 유형별 시계열

APPENDIX.SECTOR <- APPENDIX.5 # 업종별 시계열

# 5-2. 지역 BSI

APPENDIX.REGION <- BSI_REGION %>% 
  slice(3:26) %>% 
  relocate(지역, 전국,
           서울, 인천, 경기, 강원,
           부산, 울산, 경남,
           대구, 경북,
           광주, 전북, 전남,
           대전, 충북, 충남) %>% 
  mutate_at(vars(전국:충남), ROUND) # 지역별 시계열

# 6. export

FOLDER.2 <- paste0(FOLDER, '/', YEAR, '-', QUARTER, 'Q')

dir.create(FOLDER.2)

setwd(FOLDER.2)

write.xlsx(x = list(APPENDIX.1, APPENDIX.2, APPENDIX.3, APPENDIX.4, APPENDIX.5),
           sheetName = c('응답 업체 구성(p.2)', '현황 BSI(p.3)', '전망 BSI(p.4)',
                         '제조업 전체 및 분류별 통계(p.5-16)',
                         '세부 업종별 조사 통계(p.17-28)'),
           file = paste0(YEAR, '-', QUARTER, 'Q BSI 보도자료용 부표.xlsx')) # 3. 보도자료용 부표

write.xlsx(x = list(COMMENT_BAD.1, COMMENT_GOOD.1, COMMENT_BAD.2, COMMENT_GOOD.2),
           sheetName = c('매출액 부정', '매출액 긍정',
                         '매출전망 부정', '매출전망 긍정'),
           file = '주관식.xlsx') # 4. 주관식 답변(산업부 제공)

write.xlsx(x = list(APPENDIX.TYPE, APPENDIX.SECTOR),
           sheetName = c('유형별 시계열', '업종별 시계열'),
           file = paste0(YEAR, '-', QUARTER, 'Q 업종 BSI 보고서용 부표.xlsx')) # 5-1. 업종 BSI

write.xlsx(x = list(APPENDIX.REGION),
           sheetName = c('지역별 시계열'),
           file = paste0(YEAR, '-', QUARTER, 'Q 지역 BSI 보고서용 부표.xlsx')) # 5-2. 지역 BSI
