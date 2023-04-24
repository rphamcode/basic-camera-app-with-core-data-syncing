//
//  ExpandPhotoView.swift
//  basic-camera-app-with-core-data-syncing
//
//  Created by Pham on 4/24/23.
//

import SwiftUI

struct ExpandPhotoView: View {
      @State var photo: Photo

      @Environment(\.dismiss) private var dismiss
      @Environment(\.managedObjectContext) private var context
      @FetchRequest(entity: Photo.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Photo.createdAt, ascending: false)], predicate: nil, animation: .easeInOut)
            var listOfPhoto: FetchedResults<Photo>
      
      @State private var sharePhoto: Bool = false
      
      var body: some View {
            TabView(selection: $photo) {
                  ForEach(listOfPhoto) { photo in
                        VStack {
                              if let imageData = photo.image, let image = UIImage(data: imageData) {
                                    GeometryReader {
                                          let size = $0.size
                                          
                                          DownSizeImageView(image: image, size: size)
                                    }
                              }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .tag(photo)
                        .contentShape(Rectangle())
                  }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .overlay(alignment: .bottom, content: {
                  CustomPagingControlView(numberOfPages: listOfPhoto.count, currentPage: index(photo), isEnabled: false)
                        .offset(y: -15)
            })
            .navigationTitle((photo.createdAt ?? .init()).formatted(date: .numeric, time: .shortened))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
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
                  
                  ToolbarItem(placement: .bottomBar) {
                        Button {
                              sharePhoto.toggle()
                        } label: {
                              Image(systemName: "square.and.arrow.up.fill")
                                    .contentShape(Rectangle())
                                    .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                  }
                  
                  ToolbarItem(placement: .bottomBar) {
                        Button {
                              context.delete(photo)
                              if let _ = try? context.save() {
                                    dismiss()
                              }
                        } label: {
                              Image(systemName: "trash")
                                    .font(.callout)
                                    .contentShape(Rectangle())
                                    .foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                  }
            }
            .sheet(isPresented: $sharePhoto) {
                  if let imageData = photo.image, let image = UIImage(data: imageData) {
                        ShareSheetView(image: image)
                  }
            }
      }
      
      func index(_ of: Photo) -> Int {
            if let index = listOfPhoto.firstIndex(where: { i in
                  i.id == photo.id
            }) {
                  return index
            }
            
            return 0
      }
}

struct ExpandPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        ListPhotoView()
    }
}
