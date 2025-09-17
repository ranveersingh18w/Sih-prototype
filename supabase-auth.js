const { createClient } = supabase;

// Initialize Supabase client using credentials from config.js
const supabaseClient = createClient(AppConfig.SUPABASE_URL, AppConfig.SUPABASE_ANON_KEY);

async function signUp(actorId, password, fullName, phone, address, role) {
    try {
        // Directly insert user data into the users_plain table.
        // WARNING: This is highly insecure as it stores passwords in plaintext.
        const { data, error } = await supabaseClient
            .from('users_plain')
            .insert([
                {
                    'actorId': actorId,
                    'password': password,
                    'fullName': fullName,
                    'phone': phone,
                    'address': address,
                    'role': role,
                },
            ])
            .select()
            .single();

        if (error) {
            console.error('Supabase insert error:', error);
            alert(`Error creating user: ${error.message}`);
            return null;
        }

        // Return the inserted data on success
        return {
            actorId: data.actorId,
            role: data.role,
            fullName: data.fullName,
            phone: data.phone,
            address: data.address,
            password: data.password // Passing password back
        };

    } catch (e) {
        console.error('An unexpected error occurred during sign-up:', e);
        alert('An unexpected error occurred. Please try again.');
        return null;
    }
}

async function signIn(actorId, password, role) {
    try {
        // Directly check for a user with matching credentials.
        // WARNING: This is highly insecure as it compares plaintext passwords.
        const { data, error } = await supabaseClient
            .from('users_plain')
            .select('*')
            .eq('actorId', actorId)
            .eq('password', password)
            .eq('role', role)
            .single();

        if (error || !data) {
            console.error('Supabase select error:', error);
            return null; // Return null if user not found or error occurs
        }

        // Return the user data if a match is found
        return {
            actorId: data.actorId,
            role: data.role,
            fullName: data.fullName,
            phone: data.phone,
            address: data.address,
            password: data.password
        };

    } catch (e) {
        console.error('An unexpected error occurred during sign-in:', e);
        return null;
    }
}