import { useCallback,useEffect,useState } from "react";
import { api } from "./api/client";
import { useAuth } from "./auth/AuthContext";
import type { Provider,ProviderListResponse } from "./types";

const EVENT="nb-provider-self-changed";
export type ProviderSelfPatch={display_name?:string;specialty?:string|null;bio_short?:string|null;languages?:string[];clinic_name?:string|null;location?:string|null};

export function useProviderSelf(){
 const {user}=useAuth();
 const [provider,setProvider]=useState<Provider|null>(null),[loading,setLoading]=useState(true),[error,setError]=useState("");
 const load=useCallback(async()=>{setLoading(true);setError("");try{const result=await api<ProviderListResponse>("/providers");setProvider(result.providers.find(item=>item.provider_user_id===user?.id)||null)}catch(err){setError(err instanceof Error?err.message:"Unable to load provider profile.")}finally{setLoading(false)}},[user?.id]);
 useEffect(()=>{void load();const sync=()=>void load();window.addEventListener(EVENT,sync);return()=>window.removeEventListener(EVENT,sync)},[load]);
 const update=async(patch:ProviderSelfPatch):Promise<Provider>=>{
  const saved=await api<Provider>("/providers",{method:"PATCH",body:JSON.stringify(patch)});
  setProvider(saved);
  window.dispatchEvent(new Event(EVENT));
  return saved;
 };
 const uploadPhoto=async(_file:File):Promise<Provider>=>{throw new Error("Provider photo uploads are unavailable.")};
 return{provider,loading,error,load,update,uploadPhoto,editingAvailable:true};
}
