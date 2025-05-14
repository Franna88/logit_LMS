#!/usr/bin/env python3
import os
import json
import firebase_admin
from firebase_admin import credentials, firestore
import argparse

def check_firebase_structure(firebase_credentials_path):
    """
    Analyze the current structure of the Firebase database
    
    Args:
        firebase_credentials_path (str): Path to Firebase credentials JSON file
    """
    # Initialize Firebase
    cred = credentials.Certificate(firebase_credentials_path)
    
    # Check if Firebase app is already initialized
    try:
        firebase_admin.get_app()
    except ValueError:
        # If not initialized, initialize it
        firebase_admin.initialize_app(cred)
    
    # Initialize Firestore
    db = firestore.client()
    
    # Get top-level collections
    collections = db.collections()
    
    print("\n===== FIREBASE DATABASE STRUCTURE =====\n")
    
    for collection in collections:
        print(f"Collection: {collection.id}")
        
        # Get some sample documents from each collection
        docs = collection.limit(5).stream()
        
        for doc in docs:
            print(f"  - Document: {doc.id}")
            
            # Get fields from document
            doc_data = doc.to_dict()
            print(f"    Fields: {', '.join(doc_data.keys())}")
            
            # If this document has subcollections, show them
            subcollections = doc.reference.collections()
            for subcol in subcollections:
                print(f"    - Subcollection: {subcol.id}")
                
                # Get sample documents from subcollection
                subdocs = subcol.limit(3).stream()
                for subdoc in subdocs:
                    print(f"      - Document: {subdoc.id}")
    
    print("\n========= END OF STRUCTURE ===========\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Check Firebase database structure')
    parser.add_argument('firebase_credentials', help='Path to Firebase credentials JSON file')
    
    args = parser.parse_args()
    
    check_firebase_structure(args.firebase_credentials) 