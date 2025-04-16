import emailthreads
import mailbox
import os

mbox = mailbox.mbox('users_activemq_apache_org_2024-10.mbox')

for message in mbox:
    os.system(f'b4 mbox {message["Message-id"][1:-1]} -m users_activemq_apache_org_2024-10.mbox --outdir threads')
