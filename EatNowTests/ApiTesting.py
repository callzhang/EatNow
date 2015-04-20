# -*- coding: utf-8 -*-
"""
Created on Thu Apr 16 19:14:59 2015

@author: assdef
"""
import json
import os
import requests
import urllib
from datetime import datetime
import dateutil.tz
import time

#HOST='https://thawing-reef-5403.herokuapp.com'
HOST='https://dry-fortress-8563.herokuapp.com'
LAT,LON=(40.73461,-73.87629)
USER='qatest'
RESTID={'55303caae06271230032f119':
"https://irs1.4sqi.net/img/general/540x540/RI5GAuctb_D6Rl4eblJb-VuMxVFbamL0hUXgj2gLJOE.jpg"}

SLACKHOST='https://slack.com/api/chat.postMessage'
SLACKTOKEN=os.environ.get('SLACKTOKEN','0000-oooo')
#SLACKCON={'token':'xoxp-2723422764-4479201439-4524936059-cb68af','channel':'#server','text':'hello world'}

MESSAGEPOOL=[]

def PrintCallback(message):
    print message

def CatchCallback(message):
    global MESSAGEPOOL
    print message
    MESSAGEPOOL.append(message)

def ApiCall(endpoint, method='Get',payload=None):
    url=HOST+endpoint
    headers={'Content-Type':'application/json'}
    t0=time.time()
    if method=='Get':
        response=requests.get(url)       
    elif method=='Put':
        response=requests.put(url,data=json.dumps(payload),headers=headers)
    elif method=='Post':
        response=requests.post(url,data=json.dumps(payload),headers=headers)
    else:
        callback('method %s is not supported'%method)
        exit()
    
    return response,time.time()-t0


def BasicTest():
    error_flag=False
    #regular search
    callback('/search')
    endpoint='/search?'+ \
        urllib.urlencode({'username':USER,'latitude':LAT,'longitude':LON,
        'time':datetime(2014,4,10,12,0,0,tzinfo=dateutil.tz.tzoffset(None, 0)).strftime('%Y-%m-%dT%H:%M%z')})
    test=' respond 200 with valid input'
    try:
        
        res,delta=ApiCall(endpoint)
        
        if res.status_code==200 and len(res.json())>0:
            callback(test+' success (%ss)'%delta)
            data=res.json()
            RESTID={data[0]['_id']:data[0]['food_image_url']}
        else:
            raise Exception(test+' failed')
    except Exception as e:
        callback(e.message)
        callback(endpoint)        
        error_flag=True   
    
    endpoint='/search?'+\
        urllib.urlencode({'latitude':LAT,'longitude':LON,
        'time':datetime(2014,4,10,12,0,0,tzinfo=dateutil.tz.tzoffset(None, 0)).strftime('%Y-%m-%dT%H:%M%z')})
    test=' respond 400 with missing username'
    try:
        res,detal=ApiCall(endpoint)
        if res.status_code==400:
            callback(test+' success (%ss)'%delta)
        else:
            raise Exception(test+' failed')
    except Exception as e:
        callback(e.message)
        callback(endpoint)        
        error_flag=True

    callback('/user')
    endpoint='/user/qatest'
    test=' respond 200 with saved user'
    try:
        res,delta=ApiCall(endpoint)
        if res.status_code==200 and len(res.json())>0:
            callback(test+' success (%ss)'%delta)
        else:
            raise Exception(test+' failed')
    except Exception as e:
        callback(endpoint)
        callback(e.message)
        error_flag=True  
    
    endpoint='/user/stupidtest'
    test=' respond 400 with none exist user'
    try:
        res,delta=ApiCall(endpoint)
        if res.status_code==400:
            callback(test+' success (%ss)'%delta)
        else:
            raise Exception(test+' failed')
    except Exception as e:
        callback(e.message)
        callback(endpoint)        
        error_flag=True  
    
    callback('/restaurant')
    endpoint='/restaurant/'+ RESTID.keys()[0]
    test=' respond 200 with success update'
    
    try:
        payload={'img_url':[RESTID.values()[0]]*2}
        res,delta=ApiCall(endpoint,'Put',payload)
        if res.status_code==200:
            callback(test+' success (%ss)'%delta)
        else:
            raise Exception(test+' failed')
    except Exception as e:
        callback(e.message)
        callback(endpoint)
        callback(json.dumps(payload))
        error_flag=True  
    
    callback('/select')
    endpoint='/select'
    test=' respond 200 with success update'
    
    try:
        payload={'username':USER, 'restaurantId':RESTID.keys()[0],
                 'like':1,'rating':5, 
                 'date':datetime(2014,4,10,12,0,0,tzinfo=dateutil.tz.tzoffset(None, 0)).strftime('%Y-%m-%dT%H:%M%z'),
                 'location':{'latitude':LAT, 'longitude':LON, 'distance':10}}
        res,delta=ApiCall(endpoint,'Post',payload)
        if res.status_code==200:
            callback(test+' success (%ss)'%delta)       
        else:
            raise Exception(test+' failed')
    except Exception as e:
        callback(e.message)
        callback(endpoint)
        callback(json.dumps(payload))
        error_flag=True
    
    return error_flag
   

def StatsTest():
    
    import random    
    
    user=USER+str(random.random())
    callback('create user %s'%user)
    callback('search with new user')
    endpoint='/search?'+ \
        urllib.urlencode({'username':user,'latitude':LAT,'longitude':LON,
        'time':datetime(2014,4,10,12,0,0,tzinfo=dateutil.tz.tzoffset(None, 0)).strftime('%Y-%m-%dT%H:%M%z')})
    try:
        res,delta=ApiCall(endpoint)
        if res.status_code==200 and len(res.json())>0:
            data=res.json()
            score0=[(iv['name'],iv['score']['total_score']) for iv in data]
            RESTID={data[0]['_id']:data[0]['food_image_url']}
        else:
            raise Exception('no search data return, stop stats testing')
    except Exception as e:
        callback(endpoint)
        callback(e.message)
        return
      
    callback('get user score')
    endpoint='/user/%s'%user
    try:
        res,delta=ApiCall(endpoint)
        if res.status_code==200 and len(res.json())>0:
            userpreference=res.json()['preference']
        else:
            raise Exception('no user data return, stop stats testing')
    except Exception as e:
        callback(e.message) 
        callback(endpoint)        
        return

    callback('update preference with select')
    endpoint='/select'   
    try:
        payload={'username':user, 'restaurantId':RESTID.keys()[0],
                 'like':1,'rating':5, 
                 'date':datetime(2014,4,10,12,0,0,tzinfo=dateutil.tz.tzoffset(None, 0)).strftime('%Y-%m-%dT%H:%M%z'),
                 'location':{'latitude':LAT, 'longitude':LON, 'distance':10}}
        res,delta=ApiCall(endpoint,'Post',payload)
        if res.status_code==200:
            callback('update success')
        else:
            raise Exception('update failed,stop stats testing')
    except Exception as e:
        callback(e.message)
        callback(endpoint)
        callback(json.dumps(payload))        
        return
    
    callback('fetch new user data')
    endpoint='/user/%s'%user
    change_flag=False
    try:
        res,delta=ApiCall(endpoint)
        if res.status_code==200 and len(res.json())>0:
            userpreference_new=res.json()['preference']
            if len(userpreference)!=len(userpreference_new):
                callback('return user data length not match')
                return
            for ikey,iold in userpreference.iteritems():
                if ikey not in userpreference_new:
                    callback('missing: %s'%ikey)
                    change_flag=True
                if iold!=userpreference_new[ikey]:
                    change_flag=True
            if change_flag:
                callback('user score updated')
            else:
                callback('user score not updated')
                return                
        else:
            raise Exception('no user data return, stop stats testing')
    except Exception as e:
        callback(e.message) 
        callback(endpoint)        
        return
        
    if change_flag:
        callback('search again with updated user score')
        endpoint='/search?'+ \
            urllib.urlencode({'username':user,'latitude':LAT,'longitude':LON,
        'time':datetime(2014,4,1,12,0,0,tzinfo=dateutil.tz.tzoffset(None, 0)).strftime('%Y-%m-%dT%H:%M%z')})
        try:
            if res.status_code==200 and len(res.json())>0:
                res,delta=ApiCall(endpoint)
                data=res.json()
                score1=[(iv['name'],iv['score']['total_score']) for iv in data]
                callback('compare first five results')
                maxn=min(len(score0),len(score1),5)
                for iold,inew in zip(score0[:maxn],score1[:maxn]):
                    callback(str(iold)+'-->'+str(inew))
            else:
                raise Exception('no search data return, stop stats testing')
        except Exception as e:
            callback(e.message)
            callback(endpoint)            
            return

#callback=PrintCallback
callback=CatchCallback
    
if not BasicTest():
    callback('basic test passed, start stats test')  
#    StatsTest()
else: 
    callback('not all basic test passed, skip stats test')

if len(MESSAGEPOOL)>0:
    message={'token':SLACKTOKEN,'channel':'#server','text':'\n'.join(MESSAGEPOOL)}
    res=requests.get(SLACKHOST+'?'+urllib.urlencode(message))
    print res.status_code
    print res.text

