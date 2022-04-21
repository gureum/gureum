![logo](OSX/Assets.xcassets/AppIcon.appiconset/icon_256x256.png)

![platform](https://img.shields.io/badge/platform-macos-lightgrey)
[![Build Status](https://travis-ci.org/gureum/gureum.svg?branch=master)](https://travis-ci.org/gureum/gureum)

# 구름 입력기

macOS를 위한 새로운 한글 입력기

## 소개

구름 입력기는 빠르고 쓰기 편한 macOS용 한글 입력기입니다. 세 가지 가치를 목표로 개발하고 있습니다.

- **편리하게.** [libhangul](https://github.com/libhangul/libhangul) 기반으로 모아치기를 지원합니다. 모아치기 기능은 세벌식 사용자에게 특히 더 유용합니다.
- **가볍게.** 최소한의 기능만 구현하여 가볍게 돌아갑니다.
- **자유롭게.** 구름 입력기는 오픈 소스 소프트웨어입니다. 소스 코드는 BSD와 LGPL로 배포됩니다.

## 장점

- `libhangul` 기반으로 만들어져 한글 두벌식 및 세벌식 등 다양한 자판을 지원하고, 드보락 및 콜맥 등 다양한 로마자 자판도 지원합니다.
- `libhangul` 이외의 기능을 거의 사용하지 않아 가볍습니다.
- 입력기 전환을 막기 위해 쿼티 자판을 추가로 내장하고 있어 한글-쿼티 전환이 빠릅니다. 일부 환경에서 자판 전환이 느릴 때 도움을 줍니다.

## 설치

### Homebrew 사용

[Homebrew](https://brew.sh/) 사용자는 다음의 명령으로 간편하게 설치할 수 있습니다.

```sh
brew install --cask gureumkim
```

### 패키지 설치

1. [다운로드 페이지](http://bi.gureum.org)에서 가장 높은 버전의 GureumKIM1.x.pkg를 다운받아 실행하고 지시대로 설치합니다. 설치 할 디스크는 바꾸시면 안됩니다.
1. '시스템 환경설정 → 키보드 → 입력 소스'에 들어가 구름 입력기가 제공하는 입력 소스를 추가합니다.

### 수동 설치

위의 설치 과정을 마쳤음에도 입력기가 나타나지 않는다면 설치 패키지가 입력기를 올바르게 설치하지 못한 것입니다. 다음 방법으로 수동으로 설치합니다.

1. 위 다운로드 페이지에서 가장 높은 버전의 GureumKIM1.x.zip을 다운받아 압축을 해제합니다.
2. GureumKIM.app을 `/Library/Input Methods`에 복사합니다. (Finder에서 루트 디스크 선택 → 라이브러리 → Input Methods)
3. 로그아웃 후 다시 로그인하여 입력 소스에서 구름 입력기를 선택합니다.

---

- '시스템 환경설정 → 키보드 → 입력 소스'의 '메뉴 막대에서 입력 메뉴 보기' 설정을 활성화하면 화면 우측 상단에 위치한 메뉴 막대에서 입력 메뉴를 통해 입력기를 선택할 수 있습니다.
- 주 한글 자판을 선택하기 위해 사용할 한글 자판을 수동으로 한번 선택해 줍니다. `Caps Lock 키로 입력 소스 전환` 설정을 해두었다면, 다음부터는 <kbd>Caps Lock</kbd>으로 자동으로 선택한 자판으로 이동합니다.
  - <kbd>⇧Space</kbd> 등의 전통적인 단축키를 쓰고 싶으면 환경설정에서 자판 전환 단축키를 지정해 주세요.

## 제거

제거하기 전에 **사용 중인 입력기를 OS 기본 입력기로 전환**해 주세요.

### Homebrew 사용

Homebrew로 설치한 경우 다음의 명령으로 간편하게 삭제할 수 있습니다.

```sh
brew uninstall --cask gureumkim
```

### 빠른 삭제

1. `터미널.app (Terminal.app)`을 실행합니다.
2. 다음의 명령을 터미널에 입력하고 Enter 키를 눌러 명령을 실행합니다. 패스워드를 요구한다면 패스워드를 입력해 줍니다.

   ```sh
   curl -fsSL https://raw.githubusercontent.com/gureum/gureum/master/tools/uninstall.sh | bash
   ```

### 수동 삭제

1. `활성 상태 보기.app (Activity Monitor.app)`을 실행하고, 구름 입력기를 찾아 프로세스를 종료합니다.
   - `gureum`을 검색하여 빠르게 찾을 수 있습니다.
2. Finder에서 `/Library/Input Methods` 경로로 이동하여 `Gureum.app`을 삭제합니다.

## 개발 환경 설정

구름 입력기의 개발 환경을 설정하고 디버깅 할 수 있는 방법을 제공합니다. [개발하기](https://github.com/gureum/gureum/blob/master/HACKING.md) 문서를 참고해 주세요.

개선 제안과 관련된 사항은 [기여하기](https://github.com/gureum/gureum/blob/master/CONTRIBUTING.md) 문서를 참고해 주세요.

## 버그 신고

입력기 사용 중 문제가 있으면 어떤 문제가 있나 알려주시면 도움이 됩니다.

버그가 재현되는지 확인해 주시고 [이슈 페이지](https://github.com/gureum/gureum/issues)에 사용 환경과 버그를 재현하는 방법을 알려주시면 고치도록 노력하겠습니다.

이슈 템플릿 작성은 [기여하기](https://github.com/gureum/gureum/blob/master/CONTRIBUTING.md) 문서를 참고해 주세요.

## 만든 사람들

구름 입력기는 많은 분들의 도움으로 함께 개발되고 있습니다.

### 코드 기여자

[![](https://opencollective.com/gureum/contributors.svg?width=890&button=false)](https://github.com/gureum/gureum/graphs/contributors)

### 재정 후원

재정 후원은 프로젝트의 유지에 큰 힘이 됩니다. [후원하기](https://opencollective.com/gureum/contribute)

#### 개인

[![](https://opencollective.com/gureum/individuals.svg?width=890)](https://opencollective.com/gureum-app)

#### 단체

[![](https://opencollective.com/gureum/organization/0/avatar.svg)](https://opencollective.com/gureum-app/organization/0/website)
[![](https://opencollective.com/gureum/organization/1/avatar.svg)](https://opencollective.com/gureum-app/organization/1/website)
[![](https://opencollective.com/gureum/organization/2/avatar.svg)](https://opencollective.com/gureum-app/organization/2/website)
[![](https://opencollective.com/gureum/organization/3/avatar.svg)](https://opencollective.com/gureum-app/organization/3/website)
[![](https://opencollective.com/gureum/organization/4/avatar.svg)](https://opencollective.com/gureum-app/organization/4/website)
[![](https://opencollective.com/gureum/organization/5/avatar.svg)](https://opencollective.com/gureum-app/organization/5/website)
[![](https://opencollective.com/gureum/organization/6/avatar.svg)](https://opencollective.com/gureum-app/organization/6/website)
[![](https://opencollective.com/gureum/organization/7/avatar.svg)](https://opencollective.com/gureum-app/organization/7/website)
[![](https://opencollective.com/gureum/organization/8/avatar.svg)](https://opencollective.com/gureum-app/organization/8/website)
[![](https://opencollective.com/gureum/organization/9/avatar.svg)](https://opencollective.com/gureum-app/organization/9/website)
