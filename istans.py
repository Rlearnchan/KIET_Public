# istans

# 22.07.29 updated

# 0. what do you want

ID = 'ISTANS05' # 아이디
PW = 'ISTANS0500!' # 비밀번호
FOLDER = '/Users/baehyeongchan/Dropbox/Mac/Documents/GitHub/KIET_Private/istans' # 작업할 폴더

# 1. setting

import os
import pandas as pd
import time

from statistics import NormalDist
from time import sleep
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.support import expected_conditions as ec
from selenium.webdriver.support.ui import WebDriverWait

# 2. basic

os.chdir(FOLDER) # 작업 경로 변경

PERIOD_SET = pd.DataFrame([['일', '순기', '월', '격월', '분기', '반기', '년', '2년', '3년', '4년', '5년', '10년'],
                           ['D', '10D', 'M', '2M', 'Q', '2Q', 'Y', '2Y', '3Y', '4Y', '5Y', '10Y'],
                           list(range(1, 13))], # 순서 맞추기 위한 1:12 수열
                          index=['주기', '코드', '번호']).transpose() # 인덱스 붙여서 행/열 전환

RESULT = pd.DataFrame(columns = ['이름', 'ID', '주기', '항목', '분류', '시작연도', '시작세부시점', '종료연도', '종료세부시점', '소요시간', '수정여부']) # 실행 결과 담을 빈 공간

# 2-1. login

def DELAY() :
    sleep(abs(NormalDist(5, 1).samples(1)[0])) # 5초 내외 딜레이

WEB = webdriver.Chrome('./chromedriver') # 크롬 오픈
WEB.get('https://istans.or.kr/nsist') # 관리 사이트 접속

def TAG(xpath) :
    return WEB.find_element('xpath', xpath) # html 태그 찾기

TAG('//*[@id="emp_id_pseudo"]').click() # 아이디 창 클릭
TAG('//*[@id="emp_id"]').send_keys(ID) # 아이디 입력

TAG('//*[@id="pw_pseudo"]').click() # 패스워드 창 클릭
TAG('//*[@id="pw"]').send_keys(PW) # 패스워드 입력

temp = '//*[@id="ext-gen7"]/table[1]/tbody/tr/td/table/tbody/tr[1]/td' # xpath 길어서 분리
TAG(temp + '[1]/form/table/tbody/tr[2]/td[2]/table/tbody/tr[1]/td[2]/span/input').click() ; DELAY() # 로그인 버튼 클릭

WEB.switch_to.alert.dismiss() ; DELAY() # 패스워드 변경 안내창 무시
TAG(temp + '[2]/table/tbody/tr[4]/td[5]/table/tbody/tr[2]/td/table/tbody/tr/td[2]/a').click() ; DELAY() # 통계DB관리시스템 접속

# 3. loop

FILE = list(filter(lambda x : '# .xlsx' in x, os.listdir())) # 엑셀 파일 리스트

for i in list(range(0, len(FILE))) :

    START = time.time() # 시간 측정

    METADATA = FILE[i].split(' # ') # 파일 이름에서 파라미터 추출

    PARAMETER = pd.DataFrame(METADATA, 
                            index = ['이름', 'ID', '주기', '항목', '산업레벨', '분류', '시작행', '시작열', '종료열',
                                    '시작연도', '시작세부시점', '종료연도', '종료세부시점', '확장자']).transpose()

    # 3-1. search

    WINDOW_SEARCH = WEB.window_handles[-1] # 통계DB관리시스템(검색창) 윈도우

    WEB.switch_to.window(WINDOW_SEARCH) # 윈도우 전환
    WEB.switch_to.frame('tac_main_contents_tab_12122101204_body') # 프레임 전환

    TAG('//*[@id="inp_srch_tbl_id"]').clear() # 통계표 ID 지우기
    TAG('//*[@id="inp_srch_tbl_id"]').send_keys(PARAMETER.ID) # 통계표 ID 입력

    TAG('//*[@id="btn_stbl_srch"]').click() ; DELAY() # 검색 버튼 클릭

    WEB.switch_to.frame('__processbarIFrame') # 프레임 전환
    WebDriverWait(WEB, 1800).until(ec.invisibility_of_element((By.XPATH, '/html/body/div/img'))) # 조회될 때까지 대기
    
    WEB.switch_to.default_content() # 최초 프레임으로 복귀
    WEB.switch_to.frame('tac_main_contents_tab_12122101204_body') # 프레임 전환
    TAG('//*[@id="btn_dt_inpt"]').click() ; DELAY() # 수치입력 버튼 클릭

    # 3-2. insert

    WINDOW_INSERT = WEB.window_handles[-1] # 수치입력 팝업 윈도우

    WEB.switch_to.window(WINDOW_INSERT) # 윈도우 전환

    PERIOD_NUM = PERIOD_SET[PERIOD_SET.코드 == PARAMETER.주기[0]].iloc[0, 2] # 주기 구분(번호)
    temp = '//*[@id="sel_prd_input_0"]/option[' + str(PERIOD_NUM) + ']' # 주기별 xpath
    TAG(temp).click() # 주기 선택

    # 3-3. year

    YEAR_START = PARAMETER.시작연도
    YEAR_END = PARAMETER.종료연도

    TEXT_START = TAG('//*[@id="inp_strt_prd_de"]') # 시작 연도 부분
    TEXT_START.clear() # 적힌 것 지우고
    TEXT_START.send_keys(YEAR_START) # 시작 연도 입력

    TEXT_END = TAG('//*[@id="inp_end_prd_de"]') # 종료 연도 부분
    TEXT_END.clear() # 적힌 것 지우고
    TEXT_END.send_keys(YEAR_END) # 종료 연도 입력

    # 4. detail

    def WAIT() : # 로딩 대기 함수
        WEB.switch_to.frame('__processbarIFrame') # 프레임 전환
        WebDriverWait(WEB, 1800).until(ec.invisibility_of_element((By.XPATH, '/html/body/div/img'))) ; DELAY() # 조회될 때까지 대기
        
        WEB.switch_to.window(WINDOW_INSERT) # 윈도우 전환
        WEB.switch_to.frame('__processbarIFrame') # 프레임 전환
        WebDriverWait(WEB, 1800).until(ec.invisibility_of_element((By.XPATH, '/html/body/div/img'))) ; DELAY() # 표 나올 때까지 대기
        WEB.switch_to.default_content() # 최초 프레임으로 복귀

    # 4-1. month & quarter

    if PARAMETER.주기[0] == 'M' : # 월 자료라면 추가 입력

        MONTH_START = PARAMETER.시작세부시점
        MONTH_END = PARAMETER.종료세부시점

        TEXT_START.send_keys(MONTH_START) # 시작 세부시점 입력
        TEXT_END.send_keys(MONTH_END) # 종료 세부시점 입력

    if PARAMETER.주기[0] == 'Q' : # 분기 자료라면 추가 입력

        QUARTER_START = PARAMETER.시작세부시점[0][-1:]
        QUARTER_END = PARAMETER.종료세부시점[0][-1:]

        TAG('//*[@id="sel_strt_prd_de_button"]').click() # 시작 드롭다운 열기
        temp_start = '//*[@id="sel_strt_prd_de_itemTable_main"]/tbody/tr[' + QUARTER_START + ']' # 시작 세부시점 파트
        TAG(temp_start).click() # 시작 세부시점 선택

        TAG('//*[@id="sel_end_prd_de_button"]').click() # 종료 드롭다운 열기
        temp_end = '//*[@id="sel_end_prd_de_itemTable_main"]/tbody/tr[' + QUARTER_END + ']' # 종료 세부시점 파트
        TAG(temp_end).click() # 종료 세부시점 선택 

    # 4-2. variable (UN Comtrade)

    if PARAMETER.항목[0] != 'V0' : # 항목을 나눠서 업로드 한다면

        TAG('//*[@id="ahf_set_itmlist"]/a').click() # 분류/항목 선택 버튼 클릭

        WEB.switch_to.frame('ClsItmChoicePopup_iframe') ; DELAY() # 프레임 전환

        TAG('//*[@id="ahf_measure_all_left_move"]').click() # 기존 항목 삭제
        TAG('//*[@id="grd_measure_left_body_tbody"]/tr[' + PARAMETER.항목[0][-1:] + ']').click() ; DELAY()
        TAG('//*[@id="ahf_measure_right_move"]').click() ; DELAY() # 개별 반영

        TAG('//*[@id="ahf_input"]').click() ; DELAY() # 완료 버튼

        WAIT() # 표 나올 때까지 대기

    # 4-3. industry level (UN Comtrade, 광업제조업조사)

    if PARAMETER.산업레벨[0] != 'I0' : # 산업 레벨이 있다면
        
        TAG('//*[@id="ahf_set_itmlist"]/a').click() # 분류/항목 선택 버튼 클릭

        WEB.switch_to.frame('ClsItmChoicePopup_iframe') ; DELAY() # 프레임 전환

        TAG('//*[@id="sel_ov_l1_lev_input_0"]/option[' + PARAMETER.산업레벨[0][-1:] + ']').click() ; DELAY() # 산업레벨 선택
        TAG('//*[@id="ahf_ov_l1_all_right_move"]').click() ; DELAY() # 모두 반영
        
        TAG('//*[@id="ahf_input"]').click() ; DELAY() # 완료 버튼

        WAIT() # 표 나올 때까지 대기

    # 4-4. category (광업제조업조사)

    if PARAMETER.분류[0] != 'C0' : # 분류를 나눠서 업로드 한다면

        TAG('//*[@id="ahf_set_itmlist"]/a').click() # 분류/항목 선택 버튼 클릭

        WEB.switch_to.frame('ClsItmChoicePopup_iframe') ; DELAY() # 프레임 전환

        TAG('//*[@id="ahf_ov_l2_all_left_move"]').click() # 기존 분류 삭제
        TAG('//*[@id="grd_ov_l2_left_body_tbody"]/tr[' + PARAMETER.분류[0][-1:] + ']').click() ; DELAY() # 분류 선택
        TAG('//*[@id="ahf_ov_l2_right_move"]').click() ; DELAY() # 개별 반영

        TAG('//*[@id="ahf_input"]').click() ; DELAY() # 완료 버튼

        WAIT() # 표 나올 때까지 대기

    # 5. paste    

    # 5-1. excel upload

    if PARAMETER.항목[0] == 'V0' and PARAMETER.산업레벨[0] == 'I0' and PARAMETER.분류[0] == 'C0' : # 세부 세팅 없다면, 수치입력 눌러서 표 출력
        
        TAG('//*[@id="ahf_input"]').click() # 수치입력 버튼 클릭
        WEB.switch_to.frame('__processbarIFrame') # 프레임 전환
        WebDriverWait(WEB, 1800).until(ec.invisibility_of_element((By.XPATH, '/html/body/div/img'))) # 표 나올 때까지 대기
    
    WEB.switch_to.default_content() # 최초 프레임으로 복귀

    TAG('//*[@id="ahf_excel_upload"]').click() ; DELAY() # 엑셀 업로드 버튼 클릭

    WINDOW_EXCEL = WEB.window_handles[-1] # 엑셀업로드 팝업 윈도우

    WEB.switch_to.window(WINDOW_EXCEL) # 윈도우 전환

    TAG('//*[@id="inp_sheetNo"]').send_keys('1') # 시트 번호 입력
    TAG('//*[@id="inp_startRow"]').send_keys(PARAMETER.시작행) # 시작 행 입력
    TAG('//*[@id="inp_startCol"]').send_keys(PARAMETER.시작열) # 시작 열 입력
    TAG('//*[@id="inp_endCol"]').send_keys(PARAMETER.종료열) # 종료 열 입력

    TAG('//*[@id="filename"]').send_keys(FOLDER + '/' + FILE[i]) # 파일선택

    TAG('//*[@id="sendFILE"]').click() # 엑셀 업로드 버튼 클릭
    WebDriverWait(WEB, 1800).until(ec.alert_is_present()) # 알림창 뜰 때까지 대기

    # 알림창이 안 뜰 수도?

    WEB.switch_to.alert.accept() ; DELAY() # 확인 클릭

    WEB.switch_to.window(WINDOW_INSERT) # 윈도우 전환

    TAG('//*[@id="ahf_save"]').click() ; DELAY() # 수치저장 버튼 클릭
    WebDriverWait(WEB, 1800).until(ec.alert_is_present()) # 알림창 뜰 때까지 대기
    
    if WEB.switch_to.alert.text == '저장하시겠습니까?' : # 수치 변화 있는 경우
        EDIT = 'YES'
        WEB.switch_to.alert.accept() ; DELAY() # 확인 클릭
        WebDriverWait(WEB, 1800).until(ec.alert_is_present()) # 수치 변화 있다면 확인 창이 하나 더 뜸
    elif WEB.switch_to.alert.text == '작업 처리 중입니다. 처리 결과는 [작업별 처리현황]을 참조하세요.' : EDIT = 'CHECK' # 오래 걸리는 경우
    else : EDIT = 'NO' # 수치 변화 없는 경우

    WEB.switch_to.alert.accept() ; DELAY() # 확인 클릭

    END = time.time() # 시간 측정

    # 5-2. record

    TIME = round(END - START) # 소요 시간

    temp = pd.DataFrame([PARAMETER.이름[0], PARAMETER.ID[0], PARAMETER.주기[0], PARAMETER.항목[0], PARAMETER.분류[0],
                        PARAMETER.시작연도[0], PARAMETER.시작세부시점[0], PARAMETER.종료연도[0], PARAMETER.종료세부시점[0],
                        TIME, EDIT], # 메타데이터
                        columns = [i+1], # 순번
                        index = ['이름', 'ID', '주기', '항목', '분류', '시작연도', '시작세부시점', '종료연도', '종료세부시점', '소요시간', '수정여부']).transpose()

    RESULT = pd.concat([RESULT, temp]) # stacking

    # 5-3. go back

    EDIT = '' # 수정여부 초기화
    WEB.close() ; DELAY() # 수치입력 윈도우 종료

# 6. export

RESULT.to_excel(FOLDER + '/result.xlsx') # 결과 파일 출력