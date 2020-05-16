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


- `frontendshttp`: Array of dicts indicating each frontend on which the system will be listening. Default value `{'port': '80'}`. The valid keys are:
  - `address:` address to be used for `bind` keyword. Default: `'*'`.
  - `port`: port for `bind` directive. Required.
  - `maxconn`: `maconn`value. Default: `'4000'`.

- `backend`: Dictionary containing the backends servers info. The required keys are:
  - `name`: name for te backend. Since this system uses just a backend (composed of many servers) this name will be refered as default backend.
  - `cookie`: dictionary with information about the cookie. The valid keys are:
    - `name`: Name used for the cookie. Default: `{{ ansible_fqdn }}_ha`.
    - `maxidle`: lifetime of the session when the user is inactive. As the cookie has the information for the associated server backend. If the user is active in this time window the datetime of expiry is renewed. Default: `100m`.
  - `default_server_settings`: array of dicts with the default settings for servers. Each dict has just one ke-value pair. This information will ve added to the setting `default-server` as `key value`. An example for this values is:
    - `{ 'inter': '3s' }`
    - `{ 'fastinter': '1s' }`
    - `{ 'downinter': '10s' }`
    - `{ 'fall': '3' }`
    - `{ 'rise': '2' }`
  - `servers`: Array of dicts with information about each backend server. The valid keys for each dict is:
    - `peername`: name of the server. Required.
    - `address`: address to the server name. Example: `foo.example.net` or `192.168.0.1`. Required.
    - `cookie`: value used for the cookie in order to match the client with the apropiate backend server. This name will be inserted in the session cookie and will be vissible for the web browser. Required
    - `port`: Port to the server. Default: `80`.
    - `weight`: Weight directive por load balancing. Default: `1`.
    - `maxconn`: maxconn value  for the server. Default: `512`.

- `stats`: Dictionary containing the information about the stats section for being accesed via web. Optional.
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
