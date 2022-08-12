# kita2

# 22.08.11 updated

# 0. what do you want

START = 1977 # 시작연도
END = 2022 # 종료연도

FOLDER = '/Users/baehyeongchan/Dropbox/Mac/Documents/GitHub/KIET_Private/kita_mti' # 작업할 폴더
DOWNLOAD = '/Users/baehyeongchan/Dropbox/Mac/Downloads' # 다운로드 경로

# 1. setting

import os
import pandas as pd

from math import ceil
from statistics import NormalDist
from time import sleep
from selenium import webdriver

# 2. basic

os.chdir(FOLDER) # 작업 경로 변경

def DELAY() :
    sleep(abs(NormalDist(5, 1).samples(1)[0])) # 5초 내외 딜레이

def TAG(xpath) :
    return WEB.find_element('xpath', xpath) # html 태그 찾기

DATA = pd.DataFrame(columns = ['HS코드', 'MTI코드', 'SITC코드', '품목명', '연도']) # 데이터 담을 빈 그릇

WEB = webdriver.Chrome('./chromedriver') # 크롬 오픈
WEB.get('https://stat.kita.net/') # 메인 사이트 접속

TAG('//*[@id="header"]/div/div[2]/ul/li[3]/a').click() ; DELAY() # 통계가이드
TAG('//*[@id="header"]/div/div[2]/ul/li[3]/div/ul/li[3]/ul/li[1]/a').click() ; DELAY() # 한국품목코드
TAG('//*[@id="contents"]/div[1]/div/ul/li[6]/a').click() ; DELAY() # 코드연계표
TAG('//*[@id="item_type"]/option[2]').click() ; DELAY() # 품목분류

# 3. loop

for YEAR in list(range(START, END+1)) : # 연도 START ~ END

    TAG('//*[@id="sYear"]/option[' + str(2023-YEAR) + ']').click() # 년도

    # 3-1. 시작코드

    for a in list(range(10)) : # 시작코드 0 ~ 9

        TAG('//*[@id="contents"]/div[2]/form/div/div/fieldset/div[1]/label/input').clear() # 시작코드 지우기
        TAG('//*[@id="contents"]/div[2]/form/div/div/fieldset/div[1]/label/input').send_keys(a) # 시작코드
        TAG('//*[@id="contents"]/div[2]/form/div/div/fieldset/div[2]').click() ; DELAY() # 조회

        # 3-2. 페이지 그룹

        TOTAL = int(TAG('//*[@id="total_count"]').text.replace(',', '')) # 자료 수
        MAX = ceil(TOTAL/1000) # 페이지 그룹 수

        for b in list(range(MAX)) : # 페이지 그룹 1 ~ MAX

            # 3-3. 다운로드

            for c in list(range(10)) : # 페이지 1 ~ 10, dummy 11

                OLD = list(filter(lambda x : '.xls' in x, os.listdir(DOWNLOAD))) # 다운된 파일

                TAG('//*[@id="contents"]/div[2]/form/div/div/div[1]/div/a[2]').click() ; DELAY() # 다운로드

                NEW = list(filter(lambda x : '.xls' in x, os.listdir(DOWNLOAD))) # 다운된 파일 + 새 파일

                FILE = list(set(NEW) - set(OLD))[0] # 새로 다운받은 파일 이름

                temp = pd.read_excel(DOWNLOAD + '/' + FILE, header = 2) # 데이터만 읽기
                temp['연도'] = YEAR # 연도 컬럼 추가

                DATA = pd.concat([DATA, temp]) # 데이터 축적

                try : TAG('//*[@id="pageArea"]/span/a[' + str(c+1) + ']').click() ; DELAY() # 다음 페이지
                
                except :

                    TAG('//*[@id="pageArea"]/a[2]').click() ; DELAY() # 다음 10개 페이지
                    if TAG('//*[@id="pageArea"]/a[2]').get_attribute('href').startswith('https') : break # 마지막이라면 3-1 단계로 복귀

# 4. export

DATA[['연도', 'HS코드', 'MTI코드', 'SITC코드', '품목명']].to_excel(FOLDER + '/' + 'DATA.xlsx') # 열 위치 변경해서 저장
