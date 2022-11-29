# cli

# 22.11.29 updated

# 0. what do you need

FOLDER = '/Users/baehyeongchan/Dropbox/Mac/Documents/GitHub/KIET_Private/cli2' # 폴더 경로
PART = ['alu', 'coal', 'iron', 'lead', 'ng', 'ni', 'wti', 'xcu', 'znc', 'steel', 'nonfe'] # 분석 대상

# 1. setting

import os
import pandas as pd
import numpy as np

os.chdir(FOLDER) # 작업 경로 설정

# 2. compute

RESULT = pd.DataFrame() # 결과 담을 빈 그릇

for a in list(range(0, len(PART))) : 

    FILE_0 = 'data_predictor.xlsx' # 설명변수
    FILE_1 = 'weight_' + PART[a] + '.dta' # 설명변수 가중치
    FILE_2 = 'cli_' + PART[a] + '.xlsx' # 과거 cli
    FILE_3 = 'empirical_probability_' + PART[a] + '.dta' # 구간별 위기확률

    # 2-1. input

    temp = pd.read_excel(FILE_0) # 설명변수 로드

    temp = temp.dropna(axis = 0) # 결측값 있는 행 제거

    for b in list(range(1, len(temp))) :

        temp.iloc[b, 1:9] = temp.iloc[b, 1:9] / temp.iloc[0, 1:9] # 설명변수 지수화(첫 행으로 나누기)

    temp.iloc[0, 1:9] = 1 # 첫 행은 1로 변경

    temp = temp[sorted(list(temp.columns))] # column 알파벳 순으로 정렬

    INPUT = temp.set_index('yyyym') # 시점은 인덱스로

    # 2-2. cli update

    temp = pd.read_stata(FILE_1) # 설명변수 가중치 로드

    temp = temp.drop('n', axis = 1) # 의미 없는 column 제거

    for d in list(range(0, len(INPUT))) : # row 단위로 계산
        
        INPUT.iloc[d, 0:INPUT.shape[1]] = INPUT.iloc[d, 0:INPUT.shape[1]] * list(temp.iloc[0]) # 설명변수(지수화) * 가중치

    CLI = pd.DataFrame([np.sum(INPUT, axis = 1)], ['cli']).T # rowsum above(가중평균)

    # 2-3. where are you

    temp = pd.read_excel(FILE_2) # 과거 cli 로드

    temp = temp.set_index('yyyym') # 시점은 인덱스로

    MERGE = pd.concat([temp, CLI.tail(1)]) # 과거 cli + latest cli 합친 테이블

    if MERGE.cli.tail(1)[0] == min(MERGE.cli) : # cli 최소(lower outlier)

        LEVEL = 0 # 1번째 구간이라 봄

    elif MERGE.cli.tail(1)[0] == max(MERGE.cli) : # cli 최대(upper outlier)

        LEVEL = 19 # 20번째 구간이라 봄

    else : # 일반적인 경우

        for e in list(range(0, 20)) :
            
            if MERGE.cli.tail(1)[0] in pd.qcut(MERGE.cli, 20).values.categories[e] : # latest cli가 경험적 분포의 어느 수준인가(20개 구간)
                
                LEVEL = e # 해당하는 구간 기록(0~19)

    pd.DataFrame(MERGE).to_excel('new_' + FILE_2) # 새로 계산한 cli 추가해서 저장

    # 2-4. risk alret

    temp = pd.read_stata(FILE_3) # 구간별 위기확률 로드

    ALERT = pd.DataFrame([PART[a], MERGE.cli.tail(1).index[0], MERGE.cli.tail(1)[0], temp.iloc[LEVEL][0], temp.iloc[LEVEL][1]], ['part', 'time', 'cli', 'interval', 'prob']).T # 데이터 정리

    # 3. result

    RESULT = pd.concat([RESULT, ALERT]) # 연장

# 3-1. export

RESULT.set_index('part', inplace = True) # 파트는 인덱스로

RESULT.to_excel('result.xlsx') # 결과값 data frame
