# 개발환경 설정
git submodule을 포함하고 있으므로 클론 후 submodule도 가져오도록 해야합니다.

	git clone git://github.com/gureum/gureum.git # 클론
	cd gureum
	git submodule init # submodule 설정
	git submodule update # submodule 받아오기
	cd gureum/libhangul-objc
	git submodule init
	git submodule update


