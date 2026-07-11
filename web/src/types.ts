// Shared API types for the NeuroBridge clinical dashboard.
// These mirror the backend response schemas (read-only usage here).

export interface UserBasic {
  id: string;
  full_name: string;
  email?: string | null;
  phone?: string | null;
  preferred_language: string;
  status: string;
}

export interface Assignment {
  id: string;
  patient_profile_id: string;
  clinician_user_id: string;
  assignment_type: string;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export interface FamilyLink {
  id: string;
  patient_profile_id: string;
  family_user_id: string;
  relationship?: string | null;
  active: boolean;
  created_at: string;
  updated_at: string;
}

export interface PatientProfile {
  id: string;
  user_id: string;
  user?: UserBasic | null;
  date_of_birth?: string | null;
  gender?: string | null;
  emergency_contact_name?: string | null;
  emergency_contact_phone?: string | null;
  notes?: string | null;
  allergies?: string | null;
  current_medications?: string | null;
  blood_type?: string | null;
  mobility_needs?: string | null;
  vision_hearing_needs?: string | null;
  preferred_communication?: string | null;
  caregiver_notes?: string | null;
  assignments: Assignment[];
  family_links?: FamilyLink[];
  created_at: string;
  updated_at: string;
}

export interface GameDefinition {
  id: string;
  name: string;
  slug: string;
  description?: string | null;
  game_type: string;
  difficulty: string;
  estimated_duration_minutes?: number | null;
  active: boolean;
  instructions?: string | null;
}

export interface GameResult {
  id: string;
  game_definition_id: string;
  patient_profile_id: string;
  user_id: string;
  score?: number | null;
  max_score?: number | null;
  accuracy_percent?: number | null;
  duration_seconds?: number | null;
  completed: boolean;
  metrics?: Record<string, unknown> | null;
  started_at?: string | null;
  completed_at?: string | null;
  created_at: string;
}

export interface MemoryEntry {
  id: string;
  patient_profile_id: string;
  uploaded_by_user_id: string;
  title: string;
  description?: string | null;
  person_name?: string | null;
  relationship?: string | null;
  place_name?: string | null;
  memory_date?: string | null;
  category?: string | null;
  media_type?: string | null;
  media_url?: string | null;
  created_at: string;
  updated_at: string;
}

export interface PatientListResponse {
  success: boolean;
  total: number;
  patients: PatientProfile[];
}

export interface GameListResponse {
  success: boolean;
  total: number;
  games: GameDefinition[];
}

export interface GameResultListResponse {
  success: boolean;
  total: number;
  results: GameResult[];
}

export interface MemoryListResponse {
  success: boolean;
  total: number;
  memories: MemoryEntry[];
}
