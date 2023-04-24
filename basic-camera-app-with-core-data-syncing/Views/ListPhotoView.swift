//
//  ListPhotoView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI
import CoreData

struct ListPhotoView: View {
      @Environment(\.managedObjectContext) private var context
      @Environment(\.dismiss) private var dismiss
      @FetchRequest(entity: Photo.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdAt, ascending: false)], predicate: nil, animation: .easeInOut)
            var listOfPhoto: FetchedResults<Photo>
      
      var body: some View {
            NavigationStack {
                  ScrollView(.vertical, showsIndicators: false, content: {
                        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 5), count: 3), spacing: 5) {
                              ForEach(listOfPhoto) { photo in
                                    NavigationLink {
                                          ExpandPhotoView(photo: photo)
                                    } label: {
                                          GeometryReader {
                                                let size = $0.size
                                                
                                                if let imageData = photo.image, let image = UIImage(data: imageData) {
                                                      DownSizeImageView(image: image, size: size, mode: .fill)
                                                            .clipped()
                                                            .contentShape(Rectangle())
                                                }
                                          }
                                          .frame(height: 100)
                                          .contentShape(Rectangle())
                                          .contextMenu {
                                                Button("Delete", role: .destructive) {
                                                      context.delete(photo)
                                                      try? context.save()
                                                }
                                          }
                                    }
                              }
                        }
                        .padding(10)
                  })
                  .overlay {
                        if listOfPhoto.isEmpty {
                              Text("No Photo Found")
                        }
                  }
                  .navigationTitle("Photos")
                  .navigationBarTitleDisplayMode(.inline)
                  .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                              Button {
                                    dismiss()
                              } label: {
                                    Image(systemName: "chevron.left")
                                          .fontWeight(.semibold)
                                          .contentShape(Rectangle())
                                          .foregroundColor(.white)
                              }
                        }
                  }
            }
      }
}

struct ListPhotoView_Previews: PreviewProvider {
      static var previews: some View {
            ListPhotoView()
      }
}
