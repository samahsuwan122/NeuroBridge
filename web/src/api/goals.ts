import { api } from "./client";
import type {
  Goal,
  GoalCreatePayload,
  GoalListResponse,
  GoalUpdatePayload,
} from "../types";

export function listPatientGoals(patientProfileId: string): Promise<GoalListResponse> {
  return api<GoalListResponse>(`/goals/patient/${patientProfileId}`);
}

export function createGoal(payload: GoalCreatePayload): Promise<Goal> {
  return api<Goal>("/goals", {
    method: "POST",
    body: JSON.stringify(payload),
  });
}

export function updateGoal(
  goalId: string,
  payload: GoalUpdatePayload,
): Promise<Goal> {
  return api<Goal>(`/goals/${goalId}`, {
    method: "PATCH",
    body: JSON.stringify(payload),
  });
}