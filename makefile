
# ユーザID、ユーザ名、
# グループID、グループ名を取得する
user_name :=`id -un`
user_id   :=`id -u`
group_name:=`id -gn`
group_id  :=`id -g`

# dockerイメージのビルド
.PHONY: build
build:
	docker build \
		--build-arg user_name=$(user_name) \
		--build-arg user_id=$(user_id) \
		--build-arg group_name=$(group_name) \
		--build-arg group_id=$(group_id) \
		-t dev .

# dockerコンテナの起動
# -it 起動後にコンテナにログインする
# --rm コンテナからログアウト後にコンテナを削除する
.PHONY: run
run:
	xhost +si:localuser:$(user_name)
	docker run --runtime=nvidia --rm -it \
		--hostname dev \
		-v `pwd`/../volumes/test:/home/$(user_name)/test \
		-v `pwd`/../volumes/programs:/home/$(user_name)/programs \
		-e DISPLAY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-u $(user_name) dev

# dockerコンテナの起動
# CUIで起動(GUIのソフトは起動できない)
# -it 起動後にコンテナにログインする
# --rm コンテナからログアウト後にコンテナを削除する
.PHONY: cui
cui:
	docker run --runtime=nvidia --rm -it \
		--hostname dev \
		-v `pwd`/../volumes/test:/home/$(user_name)/test \
		-v `pwd`/../volumes/programs:/home/$(user_name)/programs \
		-u $(user_name) dev

#githubにアップロードを行う
.PHONY: git
git:
	git add --all .
	git commit
	git push -u origin master

