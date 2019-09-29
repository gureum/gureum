# 개발환경 설정

libhangul의 라이선스 전파성을 피하기 위해 프로젝트를 분리하여 준비가 조금 복잡합니다.
git submodule을 포함하고 있으므로 클론 후 submodule도 가져오도록 해야합니다.

``` sh
git clone https://github.com/gureum/gureum.git  # 클론
cd gureum
git submodule update --init --recursive
pod install # cocoapods을 처음 사용하면 http://cocoapods.org 에서 설치법을 확인하세요
open Gureum.xcworkspace
```

submodule의 URL 변경 등을 이유로 submodule이 제대로 클론되지 않을 경우에는 다음
명령어로 다시 가져올 수 있습니다.

``` sh
git submodule deinit -f --all
rm -rf .git/modules/*
git submodule update --init --recursive
```

또한, CocoaPods 1.6 베타 이상의 환경이 필요합니다. 경우에 따라 빌드 결과물의 경로가 변경될 수 있습니다. Xcode 10을 기준으로 Build Location 은 Unique 세팅으로 워크스페이스가 구성되어 있는지 확인해주세요.

> Xcode > Preferences > Locations > Derived Data > Advanced... > Unique

![image](https://user-images.githubusercontent.com/906974/48977266-9057a580-f0da-11e8-86a3-14a0fd4fcb48.png)

# 빌드

`OSX 타겟`을 빌드하면 의존성과 함께 구름 입력기가 빌드됩니다.

![image](https://user-images.githubusercontent.com/906974/48977284-c5fc8e80-f0da-11e8-9ad2-7a40b8e774ea.png)

Debug Configuration으로 빌드하면 Console.app 에서 로그를 확인할 수 있습니다.

# 디버그 빌드 테스트

디버그 모드로 빌드한 입력기를 설치합니다.

``` sh
cd tools
./install_debug.sh
```

설치 후에는 구름 입력기가 사라질 수 있습니다.
언어 및 입력기 설정을 다시 열고 입력기를 설정해 줍니다.

Console.app 에서 로그를 확인할 수 있습니다.

## xcode-select 에러나는 경우

설치 과정에서 xcode-select 관련 에러가 나타나는 경우

```
xcode-select: error: tool 'xcodebuild' requires Xcode, but active developer directory '/Library/Developer/CommandLineTools' is a command line tools instance something wrong
```

아래 명령어를 실행해줍니다.

``` sh
sudo xcode-select -s /Applications/Xcode.app/
```

## xcpretty 에러나는 경우

설치 과정에서 xcpretty 에러가 나타나는 경우

```
./install_debug.sh: line 6: xcpretty: command not found
```

아래 명령어를 실행해줍니다.

``` sh
sudo gem install xcpretty
```


## 디버거 사용하기

어떤 경우에도 Xcode에서 Run으로 구름을 실행하거나 빌드한 구름 앱을 직접 실행하면 **절대** 안됩니다.

`install_debug.sh`로 설치 후 Xcode에서 Attach to process 기능을 이용하여 디버거를 동작시킬 수는 있지만, 브레이크 포인트를 만들면 디버거 조작 입력이 처리가 되지 않아 디버그하기가 아주 어렵습니다.

가능한 방법 가운데 하나는 breakpoint에 입력기가 진입하면 가능한 빠르게 시스템 입력기로 되돌려서 시스템 입력기로 Xcode를 조작해 디버거를 사용하는 것입니다.

가능하면 로그와 `Console.app`을 먼저 사용해보고 디버거가 필요한 경우에만 디버거를 붙여 쓰는 것을 추천합니다.


# 커밋하기 전에

입력기의 동작을 고치셨다면, 최소한 다음의 프로그램에서 입력기가 정상적으로 동작하는지 확인해 주면 좋습니다.

* TextEdit.app : 아주 일반적인 맥의 입력환경입니다.
* Terminal.app : 한글 조합에 관한 이벤트 발생이 다른 프로그램과 조금 다릅니다. 예를 들어 한글 입력 중에는 리턴 키를 입력하더라도 조합만 해제됩니다.

특수한 입력을 처리했다면 경우에 따라 아래의 프로그램도 확인해 볼 필요가 있습니다.

* Firefox.app : 단축키 입력을 선점하지 않습니다. Modifier를 수정했다면 테스트해 보아야 합니다.
* MS 오피스 2011 : 화살표 키 등 일부 다른 프로그램에서는 전달하지 않는 키코드가 전달됩니다. (issue #3)

변경한 소스 코드에 대해 swiftformat을 실행하여 코드의 일관성을 유지해 주세요. CI 과정에서 swiftformat으로 인한 변경 사항이 발견되면 빌드는 통과되지 않습니다.

```sh
# 예시
swiftformat OSXCore/
```

