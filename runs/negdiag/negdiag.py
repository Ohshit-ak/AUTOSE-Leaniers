import json, sys
sys.path.insert(0, '/home2/akshithkandagatla/AUTOSE-Leaniers/harness')
import os; os.chdir('/home2/akshithkandagatla/AUTOSE-Leaniers/harness')
from agents.negative import NEG_PROMPT, NEG_SYSTEM, judge_bad_example, _bad_values
from agents.base import split_example
from llm import call_llm
s = json.load(open('../runs/0000 - gamma j/qwen-v6/specs.json'))
want = ['UC-customer-register-customer','UC-administrator-login-administrator','UC-sales-person-login-sales-person','5.1/R4','DD-user-id','3.3.3/S1','UC-customer-checkout-an-order','1.4/S2']
for r in s['results']:
    if r['id'] not in want or not r['checked']: continue
    code = r['lean_predicate']
    reply = call_llm(NEG_PROMPT.format(requirement=r['text_predicate'], spec=split_example(code)[0]), system=NEG_SYSTEM, model='qwen')
    v = judge_bad_example(code, reply)
    print('=====', r['id'], v['status'], '|', (v.get('error') or '')[:300])
    print('values:', _bad_values(reply))
    print(reply[:900])
