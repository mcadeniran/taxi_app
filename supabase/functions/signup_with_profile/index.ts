// supabase/functions/signup_with_profile/index.ts
import "jsr:@supabase/functions-js/edge-runtime.d.ts"

serve(async (req) => {
  try {
    const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
    const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

    const { email, password, display_name, role } = await req.json();

    if (!email || !password || !display_name || !role) {
      return new Response(JSON.stringify({ error: "Missing fields" }), {
        status: 400,
      });
    }

    // Create the user
    const { data: userData, error: signupError } = await supabase.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
    });

    if (signupError) {
      console.error("Signup error:", signupError);
      return new Response(JSON.stringify({ error: signupError.message }), {
        status: 500,
      });
    }

    const userId = userData.user?.id;
    if (!userId) {
      console.error("User ID is missing after signup.");
      return new Response(JSON.stringify({ error: "User ID missing" }), {
        status: 500,
      });
    }

    // Insert into profiles
    const { error: profileError } = await supabase.from("profiles").insert({
      id: userId,
      display_name,
      role,
    });

    if (profileError) {
      console.error("Profile insertion error:", profileError);
      return new Response(JSON.stringify({ error: profileError.message }), {
        status: 500,
      });
    }

    return new Response(JSON.stringify({ success: true }), { status: 200 });
  } catch (e) {
    console.error("Unhandled exception:", e);
    return new Response(JSON.stringify({ error: "Unexpected error", message: e.message }), {
      status: 500,
    });
  }
});
