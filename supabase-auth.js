const SUPABASE_URL = 'https://uktkljrgbkenbvvpqcbe.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVrdGtsanJnYmtlbmJ2dnBxY2JlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc5OTkwMjMsImV4cCI6MjA3MzU3NTAyM30.2KHill336u0RcXSKjEfhqWCTofAs8B0eCZ7JXsHcyrQ';

const { createClient } = supabase;
const _supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

async function signUp(actorId, password, fullName, phone, address, role) {
    const { data, error } = await _supabase
        .from('users_plain')
        .insert([
            { 
                actorId: actorId, 
                password: password, 
                fullName: fullName,
                phone: phone,
                address: address,
                role: role 
            }
        ])
        .select();

    if (error) {
        console.error('Error signing up:', error.message);
        return null;
    }

    return data ? data[0] : null;
}

async function signIn(actorId, password, role) {
    const { data, error } = await _supabase
        .from('users_plain')
        .select('*')
        .eq('actorId', actorId)
        .eq('password', password)
        .eq('role', role)
        .single();

    if (error || !data) {
        console.error('Error signing in:', error ? error.message : 'No user found');
        return null;
    }

    return data;
}