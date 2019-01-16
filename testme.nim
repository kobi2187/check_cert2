import osproc
let res = execProcess(

            "echo | openssl s_client -connect example.com:443 2>/dev/null | openssl x509 -noout -dates")
