# Домашнее задание к занятию "3.9. Элементы безопасности информационных систем"

1. Установите [Hashicorp Vault](https://learn.hashicorp.com/vault) в виртуальной машине Vagrant/VirtualBox. Это не является обязательным для выполнения задания, но для лучшего понимания что происходит при выполнении команд (посмотреть результат в UI), можно по аналогии с netdata из прошлых лекций пробросить порт Vault на localhost:

    ```bash
    config.vm.network "forwarded_port", guest: 8200, host: 8200
    ```

Однако, обратите внимание, что только-лишь проброса порта не будет достаточно – по-умолчанию Vault слушает на 127.0.0.1; добавьте к опциям запуска `-dev-listen-address="0.0.0.0:8200"`.

```
vagrant@vagrant:~$ vault -version
Vault v1.7.3 (5d517c864c8f10385bf65627891bc7ef55f5e827)
```
   
2. Запустить Vault-сервер в dev-режиме (дополнив ключ `-dev` упомянутым выше `-dev-listen-address`, если хотите увидеть UI).

```
vagrant@vagrant:~$ vault server -dev -dev-listen-address="0.0.0.0:8200"
...
Unseal Key: EKsqspuL+PAaiBIUgUCvIGsepL4lnPxNSXtwiNFYpRg=
Root Token: s.KZ0fHRDxXYkOgpa0wSjHOBOo
```

![Screenshot from 2021-07-10 23-40-29](https://user-images.githubusercontent.com/72273610/125171853-59c1f100-e1d8-11eb-9cf5-530370fb140d.png)

3. Используя [PKI Secrets Engine](https://www.vaultproject.io/docs/secrets/pki), создайте Root CA и Intermediate CA.
Обратите внимание на [дополнительные материалы](https://learn.hashicorp.com/tutorials/vault/pki-engine) по созданию CA в Vault, если с изначальной инструкцией возникнут сложности.

Задаем переменные, инициализируем PKI.

```
vagrant@vagrant:~$ export VAULT_ADDR=http://127.0.0.1:8200

vagrant@vagrant:~$ export VAULT_TOKEN=s.KZ0fHRDxXYkOgpa0wSjHOBOo

vagrant@vagrant:~$ vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
```

3.1. Создаем Root CA. 
Задаем время действия сертификата.
```
vagrant@vagrant:~$ vault secrets tune -max-lease-ttl=87600h pki
Success! Tuned the secrets engine at: pki/
```
Генерируем самоподписанный CA сертификат и приватный ключ.
```
vagrant@vagrant:~$ vault write -field=certificate pki/root/generate/internal common_name="example.com" ttl=87600h > CA_cert.crt
```
Прописываем пути для CA и CRL (certificate revocation list)
```
vagrant@vagrant:~$ vault write pki/config/urls issuing_certificates="$VAULT_ADDR/v1/pki/ca" crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
Success! Data written to: pki/config/urls
```
Проверяем:
```
vagrant@vagrant:~$ openssl x509 -in CA_cert.crt -text
...
oz9LD/RNhA3otNqUrPVRJIjASsEiTiuAGK1O01ROfJlr1D9hvQ+kqB/C5YmDGtCx
+DutoRyS7eBA
-----END CERTIFICATE-----

vagrant@vagrant:~$ openssl x509 -in CA_cert.crt -noout -dates
notBefore=Jul 12 18:46:33 2021 GMT
notAfter=Jul 10 18:47:03 2031 GMT
```

3.2. Создаем Intermidiate CA.  
Инициализируем PKI.
```
vagrant@vagrant:~$ vault secrets enable -path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/
vagrant@vagrant:~$ vault secrets tune -max-lease-ttl=43800h pki_int
Success! Tuned the secrets engine at: pki_int/
```
Генерируем Intermidiate и создаем запрос `CSR`. Сохраняем его в `pki_intermediate.csr`.
```
vagrant@vagrant:~$ vault write -format=json pki_int/intermediate/generate/internal common_name="example.com Intermediate Authority" | jq -r '.data.csr' > pki_intermediate.csr
```

4. Согласно этой же инструкции, подпишите Intermediate CA csr на сертификат для тестового домена (например, `netology.example.com` если действовали согласно инструкции).

Подписываем Intermidiate сертификат приватным ключем root CA и сохраняем сгенерированный сертификат как `intermediate.cert.pem`.
```
vagrant@vagrant:~$ vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr format=pem_bundle ttl="43800h" | jq -r '.data.certificate' > intermediate.cert.pem
```
После подписания CSR и возвращения сертификата от root CA, импортируем его в Vault:
```
vagrant@vagrant:~$ vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed
```
Создаем роль `example-dot-com` с параметром, разрешающим субдомены.
```
vagrant@vagrant:~$ vault write pki_int/roles/example-dot-com allowed_domains="example.com" allow_subdomains=true max_ttl="720h"
Success! Data written to: pki_int/roles/example-dot-com
```
Делаем запрос на сертификат для субдомена `netology.example.com`.
```
vagrant@vagrant:~$ vault write pki_int/issue/example-dot-com common_name="netology.example.com" ttl="24h"
```
Сохраняем все три сертификата.


5. Поднимите на localhost nginx, сконфигурируйте default vhost для использования подписанного Vault Intermediate CA сертификата и выбранного вами домена. Сертификат из Vault подложить в nginx руками.


Объединяем 3 сертификата, полученные на предыдущем пункте.
```
cat cert.crt iss_cert.crt chain_ca.crt >bundle.crt
```
Добавляем сертификат в nginx.
```
vagrant@vagrant:~$ sudo nano /etc/nginx/sites-enabled/default
listen 443 ssl default_server;
listen [::]:443 ssl default_server;
ssl_certificate /home/vagrant/bundle.crt;
ssl_certificate_key /home/vagrant/netology.example.com.key;
```

```
vagrant@vagrant:~$ sudo nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
```
vagrant@vagrant:~$ sudo systemctl reload nginx
vagrant@vagrant:~$ sudo systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2021-07-11 20:49:26 UTC; 24h ago
```

6. Модифицировав `/etc/hosts` и [системный trust-store](http://manpages.ubuntu.com/manpages/focal/en/man8/update-ca-certificates.8.html), добейтесь безошибочной с точки зрения HTTPS работы curl на ваш тестовый домен (отдающийся с localhost). Рекомендуется добавлять в доверенные сертификаты Intermediate CA. Root CA добавить было бы правильнее, но тогда при конфигурации nginx потребуется включить в цепочку Intermediate, что выходит за рамки лекции. Так же, пожалуйста, не добавляйте в доверенные сам сертификат хоста.

Прописываем наш домен на localhost и пробуем подключиться по https.
```
root@vagrant:/home/vagrant# echo 127.0.0.1 netology.example.com >> /etc/hosts
root@vagrant:/home/vagrant# host netology.example.com
netology.example.com has address 127.0.0.1
root@vagrant:/home/vagrant# curl -I https://netology.example.com
curl: (60) SSL certificate problem: unable to get local issuer certificate
```

Делаем символьную сылку на наш Intermediate сертификат и обновляем trust-store.
```
root@vagrant:/home/vagrant# ln -s /home/vagrant/intermediate.cert.crt /usr/local/share/ca-certificates/intermediate.cert.crt
root@vagrant:/home/vagrant# update-ca-certificates
Updating certificates in /etc/ssl/certs...
rehash: warning: skipping duplicate certificate in netology.example.com.crt
1 added, 0 removed; done.
Running hooks in /etc/ca-certificates/update.d...
done.
```

Проверяем:
```
root@vagrant:/home/vagrant# curl -I https://netology.example.com | head -n1
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
  0   612    0     0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
HTTP/1.1 200 OK
```

7. [Ознакомьтесь](https://letsencrypt.org/ru/docs/client-options/) с протоколом ACME и CA Let's encrypt. Если у вас есть во владении доменное имя с платным TLS-сертификатом, который возможно заменить на LE, или же без HTTPS вообще, попробуйте воспользоваться одним из предложенных клиентов, чтобы сделать веб-сайт безопасным (или перестать платить за коммерческий сертификат).

**Дополнительное задание вне зачета.** Вместо ручного подкладывания сертификата в nginx, воспользуйтесь [consul-template](https://medium.com/hashicorp-engineering/pki-as-a-service-with-hashicorp-vault-a8d075ece9a) для автоматического подтягивания сертификата из Vault.
