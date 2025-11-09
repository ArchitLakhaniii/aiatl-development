"""
Cloudflare Workers adapter for FastAPI backend.
This file adapts the FastAPI application to run on Cloudflare Workers Python runtime.
"""
from backend.app import app

# Cloudflare Workers Python runtime expects an ASGI application
# FastAPI is already ASGI-compliant, so we can export it directly
async def on_fetch(request, env):
    """
    Cloudflare Workers fetch handler.
    
    Args:
        request: The incoming request object
        env: Environment bindings (secrets, KV namespaces, etc.)
    
    Returns:
        Response object
    """
    # Import the ASGI adapter for Cloudflare Workers
    from asgiref.wsgi import ASGIAdapter
    
    # Set environment variables from bindings
    import os
    if hasattr(env, 'MONGODB_URI'):
        os.environ['MONGODB_URI'] = env.MONGODB_URI
    if hasattr(env, 'DB_NAME'):
        os.environ['DB_NAME'] = env.DB_NAME
    if hasattr(env, 'JWT_SECRET'):
        os.environ['JWT_SECRET'] = env.JWT_SECRET
    if hasattr(env, 'GEMINI_SERVICE_URL'):
        os.environ['GEMINI_SERVICE_URL'] = env.GEMINI_SERVICE_URL
    
    # Return the ASGI app
    return app
