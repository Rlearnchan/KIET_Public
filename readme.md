# bigpie

[빅파이낸스 산업 데이터]

1. 폴더 내 다음 파일들이 있는지 확인 (크롤링 도구)

 - chromedriver.exe
 - geckodriver.exe
 - selenium-server-standalone-4.0.0-alpha-1.jar

2. bigpie.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - ID : 아이디
 - PW : 비밀번호

3. 0~2 단계 실행 (로그인 이전)

 - 크롬 창을 띄운 뒤, 다운로드 경로를 작업 폴더로 지정해야 함
 - 설정 - 다운로드 - 위치 순으로 진입
 - 추가로, 크롬 창을 확대해줘야 다운로드 버튼이 표시되므로, 가급적 최대화할 것

4. 3~4 단계 실행 (루프, 엑셀 출력)

5. 폴더에 데이터 원자료와, 메타데이터 엑셀 파일이 생성 

 - 각각 'Aicel_항목이름', 'YYYY-MM-DD 데이터 정보' 식으로 네이밍 

# blackrock

[블랙록 차트 데이터]

1. blackrock.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - LATEST : 데이터별 최근 업로드 일자 (아래서 자세히 설명)

2. 전부 실행 (ctrl+a, ctrl+enter)

3. 폴더에 새로운 엑셀 파일 생성

 - overwrite 기능을 켜두었으니, 이전 파일이 삭제되길 원치 않다면 폴더 밖으로 옮겨둬야 함

 <최근 업로드 일자 확인>

 - Geopolitical, Trade : 반응형 차트에 직접 마우스 커서 놓고 확인
 - Growth, Inflation : 차트 아래 source 부분

# bsi

[제조업경기조사 부표 만들기]

1. 통계 업체서 받은 원자료 파일을 폴더에 옮김

2. bsi.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - YEAR : 연도
 - QUARTER : 분기
 - FILE : 결과표 엑셀 파일

3. 전부 실행 (ctrl+a, ctrl+enter)

4. 폴더에 'YYYY-QQ' 식으로 새로운 폴더, 더불어 엑셀 파일이 생성

5. 엑셀 파일로 보도자료 부표, 보고서 부표, 산자부용 주관식 정리 만들면 됨

 - 부표에 붙여넣기 전, '휴먼명조, 9pt, 가운데 정렬' 처럼 엑셀에서 글꼴을 일괄 바꿔주는 게 편함
 - 중국 bsi 보고서 부표는 보도자료 부표를 옮겨 작업 (22.04.18 기준)

# budgetcode

[정부 예결산 코드 매칭]

1. budgetcode.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - INPUT : 부처별 20, 21, 22년 예산 시트 파일
 - OUTPUT : 저장할 파일 이름

2. 전부 실행 (ctrl+a, ctrl+enter)

3. 폴더에 새로운 엑셀 파일 생성

# chinacheck

[중국진출기업 응답 정합성 체크]

1. 검증용 raw data 파일을 열어서, 첫 번째 row(한글로 된 문항 설명)는 삭제하고 저장

 - 공란이 많아서 R에서 직접 로드 시 다소 번잡함

2. bsi_chinacheck.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - YEAR : 연도
 - QUARTER : 분기
 - FILE : 검증용 raw data 엑셀 파일
 - FOLDER : 작업 경로

3. 전부 실행 (ctrl+a, ctrl+enter)

4. 폴더에 'YYYY-QQ' 식으로 새로운 폴더, 더불어 엑셀 파일이 생성

5. 엑셀 파일 열고, FALSE는 전부 제거

 - ctrl+f - '바꾸기' 탭 - '찾을 내용'을 'FALSE', '바꿀 내용'을 ' ' 공란으로 지정 - 모두 바꾸기

6. TRUE가 있는 부분은 오류, 이에 기반해 원자료에 정합성 체크 결과 표시(오류 색칠)

 <에러 구분>

 - error1 : 세 지역 사업비율 합계 100 아님
 - error2-5 : 해당 지역에서 사업을 한다고 답했으나, 판매 실적(현황)을 적지 않음
 - error6-8 : 판매 실적(현황)과 전망을 함께 적어야 하나, 미비한 부분이 있음
 - error9-14 : 기타 질문에서 실적/전망 응답이 대칭적이지 않음 (error6-8과 같은 맥락)

# cli

[원자재 조기경보]

1. data_predictor.xlsx 열어서 새로운 input 추가

 - 지난 달에 이어서 작업한다면, 'new_cli_원자재.xlsx' 파일들의 이름을 'cli_원자재.xlsx'로 고쳐야 함

2. cli.py 전체 실행

3. 생성된 result.xlsx 확인

# dobby

[자동퇴근 프로그램]

1. 폴더 내 다음 파일들이 있는지 확인 (크롤링 도구)

 - chromedriver.exe
 - geckodriver.exe
 - selenium-server-standalone-4.0.0-alpha-1.jar

2. dobby.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - WHEN : 퇴근체크 예정 시각, 실제로는 지정한 것보다 1-2분 늦게 찍힘
 - ID : 포털 아이디
 - PW : 포털 비밀번호
 - SHUTDOWN : 컴퓨터 종료 여부, 'YES'로 적어야만 전원 꺼짐

3. 전부 실행 (ctrl+a, ctrl+enter)

 - 퇴근 시까지, RStudio Console(왼쪽 하단) 창에 5분마다 진행 상황이 표시됨

# istans

[ISTANS 데이터 업로드]

1. 업로드 파일 가공

 - ISTANS 관리 시스템 접속, 수정할 통계표 검색, 수치입력 창에서 엑셀 다운로드 버튼 클릭
 - 해당 엑셀 파일은 일종의 가이드라인으로, row/column 주어진 대로 기존 데이터를 맞춰야 함
 - row/column이 너무 많다면 '통계표 초기조회 조건'을 설정, 분류/항목을 적절히 재배치해야 함
 - 테스트 통계표를 만들어둔 바, 상기 내용을 체크해봐도 좋을 듯
 - 가공을 마친 파일은 규칙에 따라 이름 지어둘 것 

2. 파이썬 초기 세팅

 - Anaconda 설치
 - 가상환경 활성화 : Anaconda prompt 실행, '개인설치경로:\Anaconda3\Scripts\activate base' 입력
 - 라이브러리 설치 : Anaconda prompt 실행, 'conda install selenium' 입력
 
 - Visual Studio Code 설치
 - 확장 설치 : 한국어 입력기(최초 실행 시 우측 하단에 알림), python(확장 탭에서 직접 검색)
 - 명령 팔레트(좌측 하단 톱니바퀴)에서 terminal select default profile = command prompt로 설정
 
3. 폴더 내 다음 파일들이 있는지 확인 (크롤링 도구)

 - chromedriver.exe

4. istans.py 열어서 '0. what do you need' 파트의 다음 항목 수정

 - ID : 아이디
 - PW : 패스워드
 - FOLDER : 작업 경로
 
5. 전부 실행 (ctrl+F5)

6. 폴더에 'result.xlsx' 파일이 생성

 - 업로드한 순서대로 메타데이터, 소요시간, 수정여부 등이 기재
 - 수 분 소요되는 파일은 수정여부 미확인(CHECK) 이므로, 시스템 내 '작업별 관리현황' 페이지 참고

 <테스트 통계표 목록>

 - DT_TEST_GWANGJEJO : 통계청 광업제조업 주요지표 / 산업 5레벨 선택 + '경영조직별' 분류를 row로 이동
 - DT_TEST_UNTRADE : UN 아프리카 무역 / 산업 3레벨 선택 + 항목 (수입, 수출액) 개별 선택 + '산업별' 분류를 column으로 이동
 - DT_TEST_HWANYUL : 한은 주요국 환율 / 월, 분기, 연 자료 따로 업로드

 <네이밍 규칙>

 - 별칭 # 통계표ID # 주기 # 항목 # 산업레벨 # 분류 # 시작행 # 시작열 # 종료열 # 시작연도 # 시작세부시점 # 종료연도 # 종료세부시점 # .xlsx
 
 - 주기 : M (월), Q (분기), Y (연)
 - 항목 : V0 (전부 선택), V1 (첫 번째 세부 항목만 선택), ..., V6
 - 산업레벨 : I0 (해당 없음), I3 (산업별 3레벨까지 선택), I5 (산업별 5레벨까지 선택)
 - 분류 : C0 (전부 선택), C1 (첫 번째 세부 분류만 선택), ..., C6
 - 시작행, 시작열, 종료열 : 엑셀 시트의 수치값 영역
 - 시작연도, 종료연도 : 연도 입력
 - 시작세부시점, 종료세부시점 : 월, 분기 추가 입력

 <네이밍 예시>

 - 광업제조업 # DT_TEST_GWANGJEJO # Y # V0 # I5 # C3 # 4 # E # CZ # 1991 # 00 # 1991 # 00 # .xlsx

 - 주기 : Y (연)
 - 항목 : V0 (연간급여액 ~ 종사자 전부 선택)
 - 산업레벨 : I5 (KSIC5까지 분기)
 - 분류 : C3 (기타법인)
 - 시작행, 시작열, 종료열 : (4, E) ~ (?, CZ) 범위의 셀
 - 시작연도, 종료연도 : 1991 (단일 연도)
 - 시작세부시점, 종료세부시점 : 00 (연 자료라 미기재)

# kita

[무역협회 테이블]

1. 폴더 내 다음 파일들이 있는지 확인 (크롤링 도구)

 - chromedriver.exe
 - geckodriver.exe
 - selenium-server-standalone-4.0.0-alpha-1.jar

2. kita.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - A : 가공단계 설정 (리스트 박스 순서대로 1~5, 예컨대 소비재는 2)
 - ID : 아이디
 - PW : 비밀번호

3. 전부 실행 (ctrl+a, ctrl+enter)

 - console에 페이지 넘김 관련해 selenium message가 뜨지만, 작동에는 문제 없음

4. 폴더에 'kita_가공단계' 식으로 엑셀 파일이 생성

# kita2

[무역협회 한국품목코드]

1. 폴더 내 다음 파일들이 있는지 확인 (크롤링 도구)

 - chromedriver.exe

2. kita2.py 열어서 '0. what do you need' 파트의 다음 항목 수정

 - START : 시작연도
 - END : 종료연도
 - FOLDER : 작업 경로
 - DOWNLOAD : 크롬 다운로드 경로

3. 전부 실행 (ctrl+F5)

4. 폴더에 'DATA.xlsx' 파일이 생성

 - 연도, HS코드, MTI코드, SITC코드, 품목명 기재
 - 페이지 순서대로 100개 내외로 적층, 목적에 따라 sorting 필요

# news

[뉴스 수집]

1. 폴더 내 다음 파일들이 있는지 확인 (크롤링 도구)

 - chromedriver.exe
 - geckodriver.exe
 - selenium-server-standalone-4.0.0-alpha-1.jar

2. news.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - PERIOD : 몇 시간 전 기사까지 스크랩할지 지정 (default = 12, 필요에 따라 조정)

3. 전부 실행 (ctrl+a, ctrl+enter)

4. RStudio Console(왼쪽 하단) 창에 제공되는 간단한 summary 확인

5. 폴더에 'YYYY-MM-DD 뉴스' 식으로 새로운 엑셀 파일 생성

 - 같은 날 여러 번 실행할 수 있음을 고려, overwrite 기능을 켜두었으니, 이전 파일이 삭제되길 원치 않다면 폴더 밖으로 옮겨둬야 함

6. 엑셀 파일 열고, 관심 있는 제목의 기사 링크를 통해 페이지 접속

 - 링크가 담긴 셀을 더블 클릭하면 하이퍼링크(파란색, 클릭 시 인터넷 연결) 기능이 활성화되니 참고

 <제공 뉴스 목록>

 - 연합인포맥스 (전체)
 - 산업경제신문 (전체)
 - 뉴스핌 (글로벌)
 - 글로벌이코노믹 (국제)
 - 연합뉴스 (세계)
 - 뉴시스 (국제최신)
 - 뉴스1 (국제)

# psi

[전문가경기조사 부표 만들기]

1. 통계 업체서 받은 원자료 파일을 폴더에 옮김

2. psi.R 열어서 '0. what do you need' 파트의 다음 항목 수정

 - YEAR : 연도
 - MONTH : 월
 - FILE : 누적시계열 엑셀 파일

3. 전부 실행 (ctrl+a, ctrl+enter)

4. 폴더에 'YYYY-MM' 식으로 새로운 폴더, 더불어 엑셀 파일이 생성

5. 엑셀 파일로 보도자료 부표 만들면 됨

 - 부표에 붙여넣기 전, '휴먼명조, 9pt, 가운데 정렬' 처럼 엑셀에서 글꼴을 일괄 바꿔주는 게 편함
