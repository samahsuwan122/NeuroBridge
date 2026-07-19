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

export interface AssignedActivity {
  id: string;
  patient_profile_id: string;
  assigned_by_user_id: string;
  template_type: string;
  title: string;
  instructions?: string | null;
  difficulty: string;
  duration_minutes: number;
  status: string;
  generated_content?: Record<string, unknown> | null;
  created_at: string;
  completed_at?: string | null;
}

export interface AssignedActivityListResponse {
  success: boolean;
  total: number;
  activities: AssignedActivity[];
}

export interface ActivityTemplate {
  template_type: string;
  label: string;
  default_title: string;
  default_instructions: string;
  game_slug: string;
  playable: boolean;
}

export interface ActivityTemplateListResponse {
  success: boolean;
  difficulties: string[];
  templates: ActivityTemplate[];
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

export interface Encouragement {
  id: string;
  patient_profile_id: string;
  sender_user_id: string;
  message: string;
  created_at: string;
}

export interface EncouragementListResponse {
  success: boolean;
  total: number;
  encouragements: Encouragement[];
}

export interface Appointment {
  id: string;
  patient_profile_id: string;
  requester_user_id: string;
  provider_user_id?: string | null;
  provider_name?: string | null;
  preferred_date: string;
  preferred_time?: string | null;
  appointment_mode: string;
  location?: string | null;
  meeting_url?: string | null;
  reason: string;
  status: string;
  created_at: string;
  updated_at: string;
}

export interface AppointmentListResponse {
  success: boolean;
  total: number;
  appointments: Appointment[];
}

export interface Provider {
  provider_user_id: string;
  full_name: string;
  role: string;
  specialty?: string | null;
  bio_short?: string | null;
  clinic_name?: string | null;
  governorate?: string | null;
  city?: string | null;
  location?: string | null;
  experience_label?: string | null;
  phone_number_demo?: string | null;
  photo_url?: string | null;
  rating_average?: number | null;
  rating_count?: number | null;
  available_slot_count: number;
  in_person_available: boolean;
  online_available: boolean;
  next_available_date?: string | null;
}

export interface ProviderListResponse {
  success: boolean;
  providers: Provider[];
}

export interface ProviderMessage {
  id: string;
  provider_user_id: string;
  sender_user_id: string;
  patient_profile_id: string;
  message: string;
  status: string;
  created_at: string;
  provider_name?: string | null;
  sender_name?: string | null;
  patient_name?: string | null;
  latest_reply_preview?: string | null;
  latest_reply_at?: string | null;
  unread_reply_count?: number;
}

export interface ProviderMessageReply {
  id: string;
  provider_message_id: string;
  sender_user_id: string;
  sender_name?: string | null;
  body: string;
  created_at: string;
  read_at?: string | null;
}

export interface ProviderMessageThread extends ProviderMessage {
  replies: ProviderMessageReply[];
}

export interface ProviderMessageListResponse {
  success: boolean;
  total: number;
  limit: number;
  offset: number;
  messages: ProviderMessage[];
}

export interface UnreadCountResponse {
  success?: boolean;
  unread_count: number;
}

export interface AvailabilitySlot {
  id: string;
  provider_user_id: string;
  slot_date: string;
  start_time: string;
  end_time: string;
  appointment_mode: string;
  location?: string | null;
  meeting_url?: string | null;
}

export interface SlotListResponse {
  success: boolean;
  slots: AvailabilitySlot[];
}
