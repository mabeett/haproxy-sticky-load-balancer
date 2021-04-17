haproxy-sticky-load-balancer
============================

Just a load balancer with haproxy using sticky sessions.

Usually a load balancer has no state information for matching client's request with backend servers, the state information in the backends is stored in a shared storage as a dababase server. With this _recommended_ approach session information is being sent to a backend or other with no particular problems.

When the backend servers are replicated but do not have all the client state information in the shared storage the previous approach will not work as expected and the user will receive responses indicated a noninitated session from some of the backends.

In the case of not having the option of redesign the architecture of backends server with this proposed condfiguration the load balancer sends a backend-match cookie for being received in the next requests and used to send the requests to the same backend server.


	  client1    client2 client3    client4  client5  client6 
	   ____      ____     ____      ____      ____     ____   
	  |  @ |    |  ^ |   | @  |    |  ~ |    |  ^ |   |  ~ |  
	  |____|    |____|   |____|    |____|    |____|   |____|  
	  /::::/    /::::/   /::::/    /::::/    /::::/   /::::/  
	      \         |      |          |         |       /
	       \        |      |          |         |      /
	        \       |      |          |         |     /
	         \      |      |          |         |    /
	          v     v      v          v         v   v
	       .--------------------------------------------.
	       |                                            |
	       |           load balancer                    |
	       '--------------------------------------------'
	                              |
	                             /|\
	                            / | \
	                           /  |  \
	                          /   |   \
	                         /    |    \
	                        /     |     \
	                       /      |      \
	                      /       |       \
	                     /        |        \
	                    v         v         v
	                backend1  backend2  backend3
	                 ______    ______    ______ 
	                [.....°]  [.....°]  [.....°]
	                [.....°]  [.....°]  [.....°]
	                [|||||°]  [|||||°]  [|||||°]
	                [|||||°]  [|||||°]  [|||||°]
	                [_____°]  [_____°]  [_____°]
	                [__@__°]  [__^__°]  [__~__°]
	                [_____°]  [_____°]  [_____°]

Requirements
------------

Currently this role is developed for 20.04 LTS (Focal Fossa).

This role has been developed and tested with ansible 2.9.9


Role Variables
--------------


- `frontendshttp`: Array of dicts indicating each frontend on which the system will be listening. Valid keys:
  - `address:` address to be used for `bind` keyword. Default: `'*'`.
  - `port`: port for `bind` directive. Default: `80`.
  - `maxconn`: `maconn`value. Default: `'4000'`.

- `fronthttps`: Array of dicts indicating each https frontend on which the system will be listening. Valid keys:
  - `address:` address to be used for `bind` keyword. Default: `'*'`.
  - `port`: port for `bind` directive. Default: `80`.
  - `maxconn`: `maconn`value. Default: `'4000'`.
  - `crtfile`: CRT certificate file path. Default: `/etc/haproxy/testcert.crt`.

- `backend`: Dictionary containing the backends servers info. The required keys are:
  - `name`: name for te backend. Since this system uses just a backend (composed of many servers) this name will be refered as default backend.
  - `cookie`: dictionary with information about the cookie. The valid keys are:
    - `name`: Name used for the cookie. Default: `{{ ansible_fqdn }}_ha`.
    - `maxidle`: lifetime of the session when the user is inactive. As the cookie has the information for the associated server backend. If the user is active in this time window the datetime of expiry is renewed. Default: `100m`.
  - `default_server_settings`: array of dicts with the default settings for servers. Each dict has just one key-value pair. This information will be added to the setting `default-server` as `key value`.If you want to disable set this var to `no`. Default values are:
    - `{ 'inter': '3s' }`
    - `{ 'fastinter': '1s' }`
    - `{ 'downinter': '10s' }`
    - `{ 'fall': '3' }`
    - `{ 'rise': '2' }`
  - `servers`: Dictionary with each backend server.
    Each dictionary key is the server name. From now `name`.
    - `address`: address to the server name. Example: `foo.example.net` or `192.168.0.1`. Default is `{{ name }}`.
    - `port`: Port to the server. Default: `80`.
    - `weight`: Weight directive for load balancing. Default: `1`.
    - `cookie`: value used for the cookie in order to match the client with the apropiate backend server. This name will be inserted in the session cookie and will be visible for the web browser. Defauit values is going to be the first match for:
      - sha1sum for `{{ name }}-{{ address }}`.
      - sha1sum for `{{ name }}-{{ name }}`.
    - `maxconn`: maxconn value  for the server. Optional.

- `stats`: array of dictionaries containing the information about the stats section for being accessed via web. Optional.
   Valid keys in dictionary are:
  - `address`: address to listen. The default value is `127.0.0.1`.
  - `port`: Port on which listen the admin web interface. Default value is `9000`.
  - `uri`: uri on which the admin interface will be listenint. Default value is '/haproxy?stats'.
  - `realm`: Text to give for the Basic Auth dialog. DEfault value: 'Auth\ Access'.
  - `auth`: Array of dicts for the users and password valid for accessing this admin interface. The only two possible valid keys are  `user` and `pass`. The default value is:
`[ { 'user': 'fobar', 'pass': 'foopass'}, ]`.
  - `admin`: boolean indicating if the stats interfaces has admin level. Default: `no`.


Dependencies
------------

This role uses `setup` module for getting ansible facts about Distro version and release since is expected to do portings to others targets.


Example Playbook
----------------

    #!/usr/bin/env ansible-playbook
    # usually be invoqued
    # ansible-playbook -i host:port, -u root haproxy-load-balancer.yml  -e @file_vars.yml
    
    ---
    - hosts: all
      gather_facts: no
      become: yes
    
      tasks:
      - include_role:
          name: haproxy-sticky-load-balancer
      vars:
        frontendshttp:
          - address: '*'
            port: 80
            maxconn: 4000
        backend:
          name: sys-backends
          cookie:
            name: bknsrv
            maxidle: 5m
          default_server_settings:
            - inter: 3s
            - fastinter: 1s
            - downinter: 10s
            - fall: 3
            - rise: 2
          servers:
            - peername: alpha
              address: 192.168.0.103
              port: 80
              weight: 1
              maxconn: 512
              cookie: peer1
            - peername: beta
              address: 192.168.0.104
              cookie: peer2
        stats: yes # default values will be used.


License
-------

BSD

Author Information
------------------

for -vvv info:

Matías Pecchia
https://github.com/mabeett/

and many others social networks.
