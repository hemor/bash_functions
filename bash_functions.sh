function createproj() {
    local lang=$1 name=$2 port=$3 framework=$4;
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
        sed -i "/APP_PORT/ c\APP_PORT=$port" .env && docker-compose up -d;
        cd app/;
        rm dummy.txt;
        if [ $framework ]; then
    		if [ $framework == 'laravel' ]; then
    			cmdproj $lang $name "composer create-project laravel/laravel . && php artisan make:auth";
                cmdproj $lang $name "npm install";
    		elif [ $framework == 'fuelphp' ]; then
    			cmdproj $lang $name "composer create-project fuel/fuel .";
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
        stopproj $lang $name && sudo rm -rf ~/projects/$lang/$name;
        echo "$lang/$name has been deleted.";
    else
        echo "$lang/$name does not exist.";
    fi
}

function runproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
    	read -p "Do you want to chmod app files? (y/n) " -n 1 -r
    	echo
    	if [[ $REPLY =~ ^[Yy]$ ]]; then
    		chmodproj $lang $name 777;
    	fi
        cdproj $lang $name && ./start;
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
		cmdproj $lang $name "chmod $mode -R /var/www/html/";
		echo "Chmod $mode recursively applied on $lang/$name";
	else
		echo "$lang/$name does not exist.";
	fi
}

function cmdproj() {
    local lang=$1 name=$2 cmd=$3 service=$4;
    if [ -d ~/projects/$lang/$name ]; then
        cdproj $lang $name;
        if [ $service ]; then
            docker-compose exec $service /bin/bash -c "$cmd";
        else
            docker-compose exec php /bin/bash -c "$cmd";
        fi
        echo "Command has been executed in $lang/$name";
    else
        echo "$lang/$name does not exist.";
    fi
}

function ttyproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
        cmdproj $lang $name "/bin/bash";
    else
        echo "$lang/$name does not exist.";
    fi
}