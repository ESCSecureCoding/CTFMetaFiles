from flask import render_template

from CTFd.models import db
from CTFd.utils.decorators import admins_only
from CTFd.utils.user import is_admin, authed, get_current_user

from uuid import uuid4

import random 
from os import system


url = "%s.labs.secure-coding-schulung.de"
return_info = "<div class=\"row\"><div class=\"col-md-6 offset-md-3\"><p class=\"text-center\"><br>To access your target, visit <a href=\"https://%s\" target=\"_blank\">this link</a>. <br>(Please be pacient, issuing the target's certificate can take up to 30s.)</p></div></div>"
create_container = "docker run -d --network http_proxy -e \"CTF_KEY=Tet7qhXyh6AWzlV2Sh8zQWmG9CrLWRIB4\" -e \"NODE_ENV=exxeta\" -e \"VIRTUAL_PORT=%s\" -e \"VIRTUAL_HOST=%s\" -e \"LETSENCRYPT_HOST=%s\" -v /var/CTF/exxeta.yml:/juice-shop/config/exxeta.yml -p %s:3000 juice_shop"

login_info = {}

def load(app):
    @app.route('/target', methods=['GET'])
    def view_target():
        if authed():
            user = get_current_user()
            if not login_info.has_key(user.id):
                randomvalue = uuid4().hex[0:16]
                url_prefix = randomvalue[:8]
                login_info[user.id] = url%(url_prefix)
                random_port_internal = random.randint(1000,9999)
                command = create_container%(random_port_internal, login_info[user.id], login_info[user.id], random_port_internal)
                system(command)
                print(command)
            return_data = return_info%(login_info[user.id])
            return render_template('page.html', content=return_data)
        else:
            return redirect(url_for('auth.login'))