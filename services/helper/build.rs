fn main() {
    let version = std::env::var("TOKEN").unwrap_or_default();
    println!("cargo:rustc-env=TOKEN={}", version);
    println!("cargo:rerun-if-env-changed=TOKEN");

    if let Ok(service_name) = std::env::var("SERVICE_NAME") {
        println!("cargo:rustc-env=SERVICE_NAME={}", service_name);
    }
    println!("cargo:rerun-if-env-changed=SERVICE_NAME");
}
