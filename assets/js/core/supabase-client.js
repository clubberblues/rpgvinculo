(function (window) {
  'use strict';

  var SUPABASE_URL = 'https://grrgwxcagvvafdmzsmro.supabase.co';
  var SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imdycmd3eGNhZ3Z2YWZkbXpzbXJvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTAyNTY4MTQsImV4cCI6MjEwNTgzMjgxNH0.hqLiYynGXHwyUtqcbGTTa2orSStm7ko2C5R03QNmqtQ';

  if (!window.supabase || typeof window.supabase.createClient !== 'function') {
    window.VINCULO_SUPABASE_CLIENT = null;
    window.VINCULO_SUPABASE_ERROR = 'Biblioteca Supabase indisponível.';
    return;
  }

  if (!window.VINCULO_SUPABASE_CLIENT) {
    window.VINCULO_SUPABASE_CLIENT = window.supabase.createClient(
      SUPABASE_URL,
      SUPABASE_ANON_KEY
    );
  }

  window.VINCULO_SUPABASE_URL = SUPABASE_URL;
  window.VINCULO_SUPABASE_ERROR = null;
})(window);
