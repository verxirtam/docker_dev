
user_name :=`id -un`
user_id   :=`id -u`
group_name:=`id -gn`
group_id  :=`id -g`

.PHONY: build
build:
	docker build \
		--build-arg user_name=$(user_name) \
		--build-arg user_id=$(user_id) \
		--build-arg group_name=$(group_name) \
		--build-arg group_id=$(group_id) \
		-t dev .

.PHONY: run
run:
	xhost +si:localuser:$(user_name)
	docker run --runtime=nvidia --rm -it \
		--hostname dev \
		-v `pwd`/../volumes/test:/home/$(user_name)/test \
		-e DISPLAY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-u $(user_name) dev

#githubにアップロードを行う
#.PHONY: git
#git:
#	git add --all .
#	git commit
#	git push -u origin master

