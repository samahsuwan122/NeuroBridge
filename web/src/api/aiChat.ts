import { api } from "./client";

export interface AIChatMessage {
  id: string;
  session_id: string;
  role: string;
  message: string;
  assistant_response: string;
  created_at: string;
}

export const getAIChatHistory = () =>
  api<{ success: boolean; messages: AIChatMessage[] }>("/ai-chat/history");

export const sendAIChatMessage = (message: string) =>
  api<AIChatMessage>("/ai-chat/message", {
    method: "POST",
    body: JSON.stringify({ message }),
  });
