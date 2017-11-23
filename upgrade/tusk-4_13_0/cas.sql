UPDATE tusk.user_login
INNER JOIN hsdb4.user ON hsdb4.user.uid = tusk.user_login.uid
   SET tusk.user_login.cas_login = IF(hsdb4.user.cas_login > 0, hsdb4.user.cas_login, tusk.user_login.cas_login)

