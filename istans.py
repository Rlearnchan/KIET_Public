# istans

# 22.07.19 updated

# 0. what do you want

FOLDER = '/Users/baehyeongchan/Dropbox/Mac/Documents/GitHub/KIET_Public' # 메인 폴더 경로

TABLEID = 'DT_MOTIE_FI_001_CGH' # 통계표 ID

PERIOD = 'Y' # 주기
INDUSTRY = 'NO' # 산업별 구분 여부

START_ROW = '4' # 시작 행
START_COL = 'E' # 시작 열
END_COL = 'N' # 종료 열

# 1. setting

import os
import pandas as pd

from statistics import NormalDist
from time import sleep
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

os.chdir(FOLDER) # 작업 경로 변경

# 2. basic

PERIOD_SET = pd.DataFrame([['일', '순기', '월', '격월', '분기', '반기', '년', '2년', '3년', '4년', '5년', '10년'],
                               ['D', '10D', 'M', '2M', 'Q', '2Q', 'Y', '2Y', '3Y', '4Y', '5Y', '10Y'],
                               list(range(1, 13))], # 순서 맞추기 위한 1:12 수열
                              index=['주기', '코드', '번호']).transpose() # 인덱스 붙여서 행/열 전환

# 2-1. login

def DELAY() :
    sleep(abs(NormalDist(5, 1).samples(1)[0])) # 5초 내외 딜레이

WEB = webdriver.Chrome('./chromedriver') # 크롬 오픈
WEB.get('https://istans.or.kr/nsist') # 관리 사이트 접속

WEB.find_element('xpath', '//*[@id="emp_id_pseudo"]').click() # 아이디 창 클릭
WEB.find_element('xpath', '//*[@id="emp_id"]').send_keys('ISTANS05') # 아이디 입력

WEB.find_element('xpath', '//*[@id="pw_pseudo"]').click() # 패스워드 창 클릭
WEB.find_element('xpath', '//*[@id="pw"]').send_keys('ISTANS0500!') # 패스워드 입력

temp = '//*[@id="ext-gen7"]/table[1]/tbody/tr/td/table/tbody/tr[1]/td' # xpath 길어서 분리
WEB.find_element('xpath', temp + '[1]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[1]/td[2]/span/input').click() ; DELAY() # 로그인 버튼 클릭

WEB.switch_to.alert.dismiss() ; DELAY() # 패스워드 변경 안내창 무시
WEB.find_element('xpath', temp + '[2]/table/tbody/tr[4]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td[2]/a').click() ; DELAY() # 통계DB관리시스템 접속

# 2-2. search

WINDOW_SEARCH = WEB.window_handles[-1] # 통계DB관리시스템(검색창) 윈도우

WEB.switch_to.window(WINDOW_SEARCH) # 윈도우 전환
WEB.switch_to.frame('tac_main_contents_tab_12122101204_body') # 프레임 전환

WEB.find_element('xpath', '//*[@id="inp_srch_tbl_id"]').send_keys(TABLEID) # 통계표 ID 입력
WEB.find_element('xpath', '//*[@id="btn_stbl_srch"]').click() ; DELAY() # 검색 버튼 클릭
WEB.find_element('xpath', '//*[@id="btn_dt_inpt"]').click() ; DELAY() # 수치입력 버튼 클릭

# 2-3. insert

WINDOW_INSERT = WEB.window_handles[-1] # 수치입력 팝업 윈도우

WEB.switch_to.window(WINDOW_INSERT) # 윈도우 전환

PERIOD_NUM = PERIOD_SET[PERIOD_SET.코드 == PERIOD].iloc[0, 2] # 주기 구분(번호)
temp = '//*[@id="sel_prd_input_0"]/option[' + str(PERIOD_NUM) + ']' # 주기별 xpath
WEB.find_element('xpath', temp).click() # 주기 선택

# 3. data info

# 3-1. year

SUBFOLDER = FOLDER + '/' + TABLEID # 하위 폴더 경로

# 여기서 FILE로 loop 삽입

FILE_LIST = list(filter(lambda x : TABLEID in x, os.listdir(SUBFOLDER))) # 엑셀 파일 리스트

for i in list(range(0, len(FILE_LIST))) : # loop

    FILE_NAME = FILE_LIST[i] # 업로드 할 엑셀 파일

    YEAR = FILE_NAME[-9:-5] # 연도

    TEXT_START = WEB.find_element('xpath', '//*[@id="inp_strt_prd_de"]') # 시작 연도 부분
    TEXT_START.clear() # 적힌 것 지우고
    TEXT_START.send_keys(YEAR) # 시작 연도 입력

    TEXT_END = WEB.find_element('xpath', '//*[@id="inp_end_prd_de"]') # 종료 연도 부분
    TEXT_END.clear() # 적힌 것 지우고
    TEXT_END.send_keys(YEAR) # 종료 연도 입력

    # 3-2. detail

    # 여기도 for 구문 넣어야 함

    if PERIOD_NUM == 3 : # 월 자료라면 추가 입력
        
        MONTH = FILE_NAME[0:0] # 월

        TEXT_START.send_keys(MONTH) # 시작 세부시점 입력
        TEXT_END.send_keys(MONTH) # 종료 세부시점 입력

    if PERIOD_NUM == 5 : # 분기 자료라면 추가 입력

        QUARTER = FILE_NAME[0:0] # 분기

        WEB.find_element('xpath', '//*[@id="sel_strt_prd_de_button"]').click() # 시작 드롭다운 열기
        temp_start = '//*[@id="sel_strt_prd_de_itemTable_main"]/tbody/tr[' + QUARTER + ']' # 시작 세부시점 파트
        WEB.find_element('xpath', temp_start).click() # 시작 세부시점 선택

        WEB.find_element('xpath', '//*[@id="sel_end_prd_de_button"]').click() # 종료 드롭다운 열기
        temp_end = '//*[@id="sel_end_prd_de_itemTable_main"]/tbody/tr[' + QUARTER + ']' # 종료 세부시점 파트
        WEB.find_element('xpath', temp_end).click() # 종료 세부시점 선택 

    # 3-3. industry level

    if INDUSTRY == 'YES' : # 산업 레벨이 있다면
        
        WEB.find_element('xpath', '//*[@id="ahf_set_itmlist"]/a').click() # 분류/항목 선택 버튼 클릭

        WEB.switch_to.frame('ClsItmChoicePopup_iframe') ; DELAY() # 프레임 전환

        WEB.find_element('xpath', '//*[@id="sel_ov_l1_lev_input_0"]/option[5]').click() ; DELAY() # 산업 5레벨 선택
        WEB.find_element('xpath', '//*[@id="ahf_ov_l1_all_right_move"]').click() ; DELAY() # 모두 반영
        WEB.find_element('xpath', '//*[@id="ahf_input"]').click() ; DELAY() # 완료 버튼

        WEB.switch_to.default_content() # 최초 프레임으로 복귀
        WebDriverWait(WEB, 1800).until(ec.presence_of_element_located((By.XPATH, '//*[@id="piv_virtl_dt_body_table"]/tr[1]/td[1]'))) # 표 나올 때까지 대기

    # 4-1. excel upload

    if INDUSTRY != 'YES' : # 산업 레벨 없다면, 수치입력 눌러서 표 출력
        
        WEB.find_element('xpath', '//*[@id="ahf_input"]').click() # 수치입력 버튼 클릭
        WebDriverWait(WEB, 1800).until(ec.presence_of_element_located((By.XPATH, '//*[@id="piv_virtl_dt_body_table"]/tr[1]/td[1]'))) ; DELAY() # 표 나올 때까지 대기

    WEB.find_element('xpath', '//*[@id="ahf_excel_upload"]').click() ; DELAY() # 엑셀 업로드 버튼 클릭

    WINDOW_EXCEL = WEB.window_handles[-1] # 엑셀업로드 팝업 윈도우

    WEB.switch_to.window(WINDOW_EXCEL) # 윈도우 전환

    WEB.find_element('xpath', '//*[@id="inp_sheetNo"]').send_keys('1') # 시트 번호 입력
    WEB.find_element('xpath', '//*[@id="inp_startRow"]').send_keys(START_ROW) # 시작 행 입력
    WEB.find_element('xpath', '//*[@id="inp_startCol"]').send_keys(START_COL) # 시작 열 입력
    WEB.find_element('xpath', '//*[@id="inp_endCol"]').send_keys(END_COL) # 종료 열 입력

    WEB.find_element('xpath', '//*[@id="filename"]').send_keys(SUBFOLDER + '/' + FILE_NAME) # 파일선택

    WEB.find_element('xpath', '//*[@id="sendFILE"]').click() # 엑셀 업로드 버튼 클릭
    WebDriverWait(WEB, 1800).until(ec.alert_is_present()) # 알림창 뜰 때까지 대기
    WEB.switch_to.alert.accept() ; DELAY() # 확인 클릭

    WEB.switch_to.window(WINDOW_INSERT) # 윈도우 전환

    WEB.find_element('xpath', '//*[@id="ahf_save"]').click() ; DELAY() # 수치저장 버튼 클릭
    WEB.switch_to.alert.accept() ; DELAY() # 확인 클릭

    try : WEB.switch_to.alert.accept() ; DELAY() # 확인 창이 두 개 뜨면 한 번 더 클릭
    except : pass # 아니면 패스

    # 4-2. go back

    WEB.switch_to.window(WINDOW_INSERT) # 윈도우 전환
