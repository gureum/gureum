# 개발환경 설정
libhangul의 라이선스 전파성을 피하기 위해 프로젝트를 분리하여 준비가 조금 복잡합니다.
git submodule을 포함하고 있으므로 클론 후 submodule도 가져오도록 해야합니다.

	git clone git://github.com/gureum/gureum.git # 클론
	cd gureum
	git submodule update --init --recursive

# 빌드
GureumKIM 타겟을 빌드하면 의존성과 함께 구름 입력기가 빌드됩니다.
Debug Configuration으로 빌드하면 Console.app 에서 로그를 확인할 수 있습니다.

# 테스트
1. 빌드 된 입력기를 '/Library/Input Methods' 또는 '~/Library/Input Methods' 에 설치합니다.
1. Activity Monitor.app 에서 구름 입력기를 강제로 종료하여 줍니다.
1. 입력기를 구름 입력기로 선택하고 하나 이상의 입력을 시작하면 새로 로드됩니다.
1. Debug로 빌드하였다면 Console.app 에서 로그를 확인할 수 있습니다.
더 좋은 방법이 있으면 알려주세요.

# 커밋하기 전에
입력기의 동작을 고치셨다면, 최소한 다음의 프로그램에서 입력기가 정상적으로 동작하는지 확인해 주면 좋습니다.

* TextEdit.app : 아주 일반적인 맥의 입력환경입니다.
* Terminal.app : 한글 조합에 관한 이벤트 발생이 다른 프로그램과 조금 다릅니다. 예를 들어 한글 입력 중에는 리턴 키를 입력하더라도 조합만 해제됩니다.
* 네이트온 대화창 : 리턴 키 입력 시 키코드 이벤트를 발생시키지 않습니다. 대신 -cancelComposition: 이벤트를 발생시킵니다.

특수한 입력을 처리했다면 경우에 따라 아래의 프로그램도 확인해 볼 필요가 있습니다.

* Firefox.app : 단축키 입력을 선점하지 않습니다. Modifier를 수정했다면 테스트해 보아야 합니다.
* MS 오피스 2011 : 화살표 키 등 일부 다른 프로그램에서는 전달하지 않는 키코드가 전달됩니다. (issue #3)
