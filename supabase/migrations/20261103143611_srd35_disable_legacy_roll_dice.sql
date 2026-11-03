-- The active Dice is the 3D local physics tool; it submits its manual result.
-- Disable the legacy RPC that generated arbitrary server-side dice results.
REVOKE EXECUTE ON FUNCTION public.roll_dice(text,text) FROM PUBLIC,anon,authenticated;
