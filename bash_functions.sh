function createproj() {
    local lang=$1 name=$2 framework=$3;
	if [ ! -d ~/projects/$lang ]; then
		mkdir -p ~/projects/$lang;
	fi
    if [ -d ~/projects/$lang/$name ]; then
        echo "$lang/$name already exist.";
    fi
	(cd ~/projects/$lang &&
	if [ $lang == 'php' ]; then
		git clone https://github.com/hemor/docker_php_mariadb.git $name;
		cd $name;
		cp .env.example .env;
        cd app/;
        rm dummy.txt;
        if [ $framework ]; then
    		if [ $framework == 'laravel' ]; then
    			composer create-project laravel/laravel .;
    			npm install;
    		elif [ $framework == 'fuelphp' ]; then
    			composer create-project fuel/fuel .;
    		fi
    		chmodproj $lang $name 777;
        fi
	else
		echo "Project type is unsupported at the moment.";
	fi)
}

function cdproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
        cd ~/projects/$lang/$name;
    else
        echo "$lang/$name does not exist.";
    fi
}

function delproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
        stopproj $lang $name && rm -rf ~/projects/$lang/$name;
        echo "$lang/$name has been deleted.";
    else
        echo "$lang/$name does not exist.";
    fi
}

function runproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
        chmodproj $lang $name 777 && cdproj $lang $name && ./start;
        echo "$lang/$name is now running."''
    else
        echo "$lang/$name does not exist.";
    fi
}

function stopproj() {
	local lang=$1 name=$2;
	if [ -d ~/projects/$lang/$name ]; then
		docker stop $(docker ps -f "name=$name" -q) >> /dev/null 2>&1;
		docker rm $(docker ps -a -f "name=$name" -q) >> /dev/null 2>&1;
		docker volume rm $(docker volume ls -f "name=$name" -q) >> /dev/null 2>&1;
		docker network rm $(docker network ls -f "name=$name" -q) >> /dev/null 2>&1;
		echo "$lang/$name has been stopped.";
	else
		echo "$lang/$name does not exist.";
	fi
}

function chmodproj() {
	local lang=$1 name=$2 mode=$3;
	if [ -d ~/projects/$lang/$name ]; then
		cdproj $lang $name && sudo chmod $mode -R app >> /dev/null 2>&1;
		echo "Chmod $mode recursively applied on $lang/$name";
	else
		echo "$lang/$name does not exist.";
	fi
}