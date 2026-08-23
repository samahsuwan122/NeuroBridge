import type { MemoryEntry } from "../types";
export const AI_MEMORY_KEY="nb_family_ai_local_memories",AI_ENCOURAGEMENT_KEY="nb_family_ai_local_encouragements",AI_MESSAGE_DRAFT_KEY="nb_family_ai_provider_draft",AI_ACTION_EVENT="nb-family-ai-action";
export interface LocalEncouragement{id:string;patientId:string;sender:string;message:string;createdAt:string}
const read=<T>(key:string):T[]=>{try{const value=JSON.parse(localStorage.getItem(key)||"[]");return Array.isArray(value)?value:[]}catch{return[]}};
const save=<T>(key:string,value:T[])=>{localStorage.setItem(key,JSON.stringify(value));window.dispatchEvent(new Event(AI_ACTION_EVENT))};
export const readAiMemories=()=>read<MemoryEntry>(AI_MEMORY_KEY);
export const addAiMemory=(memory:MemoryEntry)=>save(AI_MEMORY_KEY,[memory,...readAiMemories()]);
export const readAiEncouragements=()=>read<LocalEncouragement>(AI_ENCOURAGEMENT_KEY);
export const addAiEncouragement=(item:LocalEncouragement)=>save(AI_ENCOURAGEMENT_KEY,[item,...readAiEncouragements()]);
export const setAiProviderDraft=(value:{patientId:string;providerId:string;body:string})=>sessionStorage.setItem(AI_MESSAGE_DRAFT_KEY,JSON.stringify(value));
export const takeAiProviderDraft=()=>{try{const raw=sessionStorage.getItem(AI_MESSAGE_DRAFT_KEY);sessionStorage.removeItem(AI_MESSAGE_DRAFT_KEY);return raw?JSON.parse(raw) as {patientId:string;providerId:string;body:string}:null}catch{return null}};
