# 개발환경 설정
libhangul의 라이선스 전파성을 피하기 위해 프로젝트를 분리하여 준비가 조금 복잡합니다.
git submodule을 포함하고 있으므로 클론 후 submodule도 가져오도록 해야합니다.

    git clone git://github.com/gureum/gureum.git # 클론
    cd gureum
    git submodule update --init --recursive
    pod install # cocoapod을 처음 사용하면 http://cocoapods.org 에서 설치법을 확인하세요
    open Gureum.xcworkspace

또한, Cocoa Pod 1.6 베타 이상의 환경이 필요합니다. 경우에 따라 빌드 결과물의 경로가 변경될 수 있습니다. Xcode 10을 기준으로 Build Location 은 Unique 세팅으로 워크스페이스가 구성되어 있는지 확인해주세요.

> Xcode > Preferences > Locations > Derived Data > Advanced... > Unique

![image](https://user-images.githubusercontent.com/906974/48977266-9057a580-f0da-11e8-86a3-14a0fd4fcb48.png)

# 빌드

`OSX 타겟`을 빌드하면 의존성과 함께 구름 입력기가 빌드됩니다.

![image](https://user-images.githubusercontent.com/906974/48977284-c5fc8e80-f0da-11e8-9ad2-7a40b8e774ea.png)

Debug Configuration으로 빌드하면 Console.app 에서 로그를 확인할 수 있습니다.

# 테스트
디버그 모드로 빌드한 입력기를 설치합니다.

    cd tools
    ./install_debug.sh

설치 후에는 구름 입력기가 사라질 수 있습니다.
언어 및 입력기 설정을 다시 열고 입력기를 설정해 줍니다.

Console.app 에서 로그를 확인할 수 있습니다.

XCode에서 Attach to process 기능을 이용하여 디버거를 동작시킬 수는 있지만, 브레이크 포인트를 만들면 디버거 조작 입력이 처리가 되지 않아 디버그하기가 어렵습니다.

더 좋은 방법이 있으면 알려주세요.

# 커밋하기 전에
입력기의 동작을 고치셨다면, 최소한 다음의 프로그램에서 입력기가 정상적으로 동작하는지 확인해 주면 좋습니다.

* TextEdit.app : 아주 일반적인 맥의 입력환경입니다.
* Terminal.app : 한글 조합에 관한 이벤트 발생이 다른 프로그램과 조금 다릅니다. 예를 들어 한글 입력 중에는 리턴 키를 입력하더라도 조합만 해제됩니다.
* 네이트온 대화창 : 리턴 키 입력 시 키코드 이벤트를 발생시키지 않습니다. 대신 -cancelComposition: 이벤트를 발생시킵니다.

특수한 입력을 처리했다면 경우에 따라 아래의 프로그램도 확인해 볼 필요가 있습니다.

* Firefox.app : 단축키 입력을 선점하지 않습니다. Modifier를 수정했다면 테스트해 보아야 합니다.
* MS 오피스 2011 : 화살표 키 등 일부 다른 프로그램에서는 전달하지 않는 키코드가 전달됩니다. (issue #3)
