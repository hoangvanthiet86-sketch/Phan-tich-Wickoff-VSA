import math
MAX_DISTANCE_ATR = 0.50

def finite(x):
    return isinstance(x,(int,float)) and math.isfinite(x)

def origin(row):
    cc=row.get("no_supply_candidate_code")
    cv=row.get("no_supply_candidate_valid")==1
    low=row.get("low"); close=row.get("close")
    pv=row.get("price_valid")==1 and finite(low) and finite(close) and close>0 and low<=close
    sp=row.get("pivot_low_prior_price")
    pc=row.get("pivot_low_prior_confirm_bar_index")
    bi=row.get("bar_index")
    sv=(row.get("pivot_low_prior_valid")==1 and finite(sp) and sp>0 and
        isinstance(pc,int) and isinstance(bi,int) and pc<bi)
    atr=row.get("prior_atr")
    av=row.get("prior_atr_valid")==1 and finite(atr) and atr>0
    if not cv or cc not in (1,2) or not pv:
        return {"code":0,"valid":0,"reason":6}
    if not sv:
        return {"code":0,"valid":0,"reason":2}
    if not av:
        return {"code":0,"valid":0,"reason":3}
    dist=(low-sp)/atr
    if cc!=2:
        return {"code":1,"valid":1,"reason":1}
    if low<sp:
        return {"code":1,"valid":1,"reason":5}
    if low>sp+MAX_DISTANCE_ATR*atr:
        return {"code":1,"valid":1,"reason":4}
    return {"code":2,"valid":1,"reason":0,"support_price":sp,
            "support_distance_atr":dist,
            "support_pivot_extreme_bar_index":row.get("pivot_low_prior_extreme_bar_index"),
            "support_pivot_confirm_bar_index":pc,
            "origin_bar_index":bi,"origin_datetime":row.get("datetime"),
            "prior_atr":atr}

def _carry(po,res,row):
    res=dict(res)
    for k in ("support_price","support_distance_atr","support_pivot_extreme_bar_index",
              "support_pivot_confirm_bar_index","origin_bar_index","origin_datetime","prior_atr"):
        res[k]=po.get(k)
    res["evaluation_bar_index"]=row.get("bar_index")
    res["evaluation_datetime"]=row.get("datetime")
    return res

def resolution(row,po):
    if po.get("code")!=2:
        return {"code":1,"valid":1,"confirmed":0,"reason":0}
    low=row.get("low"); close=row.get("close")
    pv=row.get("price_valid")==1 and finite(low) and finite(close) and close>0 and low<=close
    status=row.get("ce_no_supply_status_code")
    conf=row.get("ce_no_supply_confirmed")
    cbi=row.get("ce_no_supply_candidate_bar_index")
    ev=row.get("ce_no_supply_evaluation_valid")==1
    if not pv or not ev or status not in (2,3) or conf not in (0,1):
        return _carry(po,{"code":0,"valid":0,"confirmed":0,"reason":5},row)
    if cbi!=po["origin_bar_index"]:
        return _carry(po,{"code":0,"valid":0,"confirmed":0,"reason":4},row)
    ce_ok=status==3 and conf==1
    held=low>=po["support_price"]
    if ce_ok and held:
        return _carry(po,{"code":3,"valid":1,"confirmed":1,"reason":0},row)
    reason=3 if (not ce_ok and not held) else 1 if not ce_ok else 2
    return _carry(po,{"code":2,"valid":1,"confirmed":0,"reason":reason},row)

def evaluate(rows):
    out=[]; po={"code":1}
    for row in rows:
        o=origin(row); r=resolution(row,po)
        out.append({"origin":o,"resolution":r})
        po=o
    return out
