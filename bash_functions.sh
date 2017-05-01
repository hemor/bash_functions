function createproj() {
    local lang=$1 name=$2 framework=$3;
	if [ ! -d ~/projects/$lang ]; then
		mkdir -p ~/projects/$lang;
	fi
    if [ -d ~/projects/$lang/$name ]; then
        echo "Project already exist.";
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
            chmod 777 -R .;
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
        echo "Project does not exist.";
    fi
}

function delproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
        rm -rf ~/projects/$lang/$name;
        echo "Project has been deleted.";
    else
        echo "Project does not exist.";
    fi
}

function runproj() {
    local lang=$1 name=$2;
    if [ -d ~/projects/$lang/$name ]; then
        cdproj $lang $name && ./start;
    else
        echo "Project does not exist.";
    fi
}