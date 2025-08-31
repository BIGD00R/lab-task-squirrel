Victor Chavez
Z# 23506428

This is a project for task keeping to ensure objectives are completed they require both a photo for proof the task has been done and to be chekced off to ensure motivations of the task to be completed as swiftly as possible
Features
Required Features
View a list of tasks to be completed for the scavenger hunt
A Task data model will have properties for title, description, image (of type UIImage?), and isComplete (a computed property which returns true if image is non-nil.
This list will show the title property
Tap into a task to see its details
title, description, isCompleted, an annotation in an MKMapView that contains the attached photo
If there’s no photo attached, hide the map view and show an “Attach Photo” button instead
Hide “Attach Photo” button once the user attaches a photo and show the map view instead
Attach a photo inside of the task detail view
Doing this marks the task as completed in both the detail view and task list
View the location of the photo in a map inside of the task view
Lab Instructions
Step 0: Setup your project
Download the Task Squirrel - starter project here:  lab_1.zip
📲 Whenever possible, it's almost always a better and more realistic development experience to run your projects on a physical iOS device vs the Xcode simulator. Particularly in a cases, such as this app, where we want to access photo library photos and associated metadata like location. Exceptions to this would be, of course if you don't have a physical device available, or when testing your app on various size devices that you don't have physical versions of.
Run the starter project and familiarize yourself with the setup and flow
The app launches to the "Tasks" screen (TaskListViewController) with a few tasks showing in a list (i.e. TableView). Each row shows the task's title and has an image to the left which indicates if the task is completed.
Back in Xcode, open the TaskListViewController file. It's a pretty straightforward, just a standard table view setup and some logic in the prepare(for segue:sender:) to coordinate navigation and passing data.
Open the Task file and you'll see that along with the Task data model, there is an extension where a static property mockedTasks has been added which just returns an array of hardcoded tasks. Feel free to edit the existing mock tasks or add your own. You can also remove them completely if you prefer, as the next step outlines how to create tasks through the app.
Back in the app, Tap the "+" button (right side of nav bar) to present the "Compose" screen (TaskComposeViewController). Fill out both "Title" and "Description" text fields and tap the "Done" button in the Nav bar to create a new task and add it to the list.
In Xcode, the new task gets passed back to the TaskListViewController via a closure set on the TaskComposeViewController in the prepareFor(for segue:sender:) method.
In the app, from the "Tasks" screen, tap on any task row to navigate to the detail screen for tapped task (TaskDetailViewController). Similar to tasks viewed in the main list, the detail screen shows an indicator for the task completion status as well as the task title. Additionally, you'll see the task's description as well as a button to "Attach Photo".
Tapping the "Attach Photo" button should present an image picker for user's to choose a photo to prove that their task has been completed, however it doesn't currently do anything at the moment...and that's exactly what you'll be doing in the next step!
Step 1: Get authorization to access the user's photo library

In order to access APIs related to accessing the user's photo library, you'll need to import the PhotosUI framework. Open the TaskDetailViewController, and at the top of the file, add import PhotosUI.


Next, locate the didTapAttachPhotoButton method, this is an method/action that's called when the "Attach Photo" button is tapped. For the purposes of this app, along with allowing the user to choose a photo from the library, we need to access metadata from the chosen photo in order to get the location data for where the photo was taken. Since metadata like location is obviously sensitive, we'll need to get the user's explicit authorization to access their photo library. Add the following to check and request photo library authorization if needed.

// If authorized, show photo picker, otherwise request authorization.
// If authorization denied, show alert with option to go to settings to update authorization.
if PHPhotoLibrary.authorizationStatus(for: .readWrite) != .authorized {
    // Request photo library access
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { [weak self] status in
        switch status {
        case .authorized:
            // The user authorized access to their photo library
            // show picker (on main thread)
            DispatchQueue.main.async {
                self?.presentImagePicker()
            }
        default:
            // show settings alert (on main thread)
            DispatchQueue.main.async {
                // Helper method to show settings alert
                self?.presentGoToSettingsAlert()
            }
        }
    }
} else {
    // Show photo picker
    presentImagePicker()
}

Run the app, tap a task to navigate to the detail screen, and tap the "Attach Photo" button...

...and crash ❌. Check the console and you should see an error message that says something like...

This app has crashed because it attempted to access privacy-sensitive data without a usage description. The app's Info.plist must contain an NSPhotoLibraryUsageDescription key with a string value explaining to the user how the app uses this data.
AI opportunity

Use AI to explain unfamiliar terms → Understanding errors
So, as the error message says, we need to add the NSPhotoLibraryUsageDescription key (with a description string of why your app needs photo library access) to the Info.plist.


Open the Info.plist and right-click in any open space. From the drop down menu, choose "Add Row". In the new row, add the NSPhotoLibraryUsageDescription key. In the value section, type a description, something like "We need access to your photos in order to add a photo to complete a task." This is the description that will be shown to the user when the system alert is shown to prompt them to authorize photo library access.


Run the app again, tap a task to navigate to the detail screen and tap the "Attach Photo" button. This time, the app shouldn't crash and instead, you'll be presented with an alert prompting photo library access featuring your description you added to the Info.plist. Choose "Allow Access to All Photos"...and well, that's it...the alert dismisses but no photo picker. We'll take care of that in the next step!

Step 2: Create, setup and present the image picker

Back in the TaskDetailViewController, locate the presentImagePicker() method and add the following to present an image picker.

// Create a configuration object
var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())

// Set the filter to only show images as options (i.e. no videos, etc.).
config.filter = .images

// Request the original file format. Fastest method as it avoids transcoding.
config.preferredAssetRepresentationMode = .current

// Only allow 1 image to be selected at a time.
config.selectionLimit = 1

// Instantiate a picker, passing in the configuration.
let picker = PHPickerViewController(configuration: config)

// Set the picker delegate so we can receive whatever image the user picks.
picker.delegate = self

// Present the picker.
present(picker, animated: true)
AI opportunity

Use AI to explain code concepts → Allowing users to pick images

Now, you're probably seeing a compiler error that says something like...

Cannot assign value of type 'TaskDetailViewController' to type '(any PHPickerViewControllerDelegate)?'
Add missing conformance to 'PHPickerViewControllerDelegate' to class 'TaskDetailViewController'

This is because in the above snippet, we assigned self (in this case the TaskDetailViewController) as the delegate for the PHPickerViewController. As the compiler suggests, we need to conform to the PHPickerViewControllerDelegate and implement any required methods. At the bottom of the file, outside of the TaskDetailViewController declaration, add an extension that declares the TaskDetailViewController conforms to the PHPickerViewControllerDelegate.

extension TaskDetailViewController: PHPickerViewControllerDelegate {

}

Just one more compiler error to deal with. Click on the red error, and it should expand to show more info with a button to "Fix".

Type 'TaskDetailViewController' does not conform to protocol 'PHPickerViewControllerDelegate'
Do you want to add protocol stubs?

Choose the "Fix" button and the compiler will add the required delegate method. This is the method that's called when the user chooses a photo from the photo picker. Leave the body of this delegate method empty for now, we'll add code to get the picked image in the next step.

func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    // This is where we'll get the picked image in the next step...
}

Run the app, navigate to the detail screen and tap the "Attach Photo" button, and this time...you should see the photo picker presented! The only issue is that tapping a photo doesn't really do anything and the only way to get out of the picker at this point is to pull to dismiss it, but we don't have access to the chosen photo...yet.

Step 3: Get the location metadata from the chosen photo
In order to get the location data from an image, we need to work with images with real location metadata. A good place to get that is from actual photos you've taken by running the app on a real physical device. However, you don't have a physical device handy, you can add photos you've taken to the simulator. To do that, open the Photos app on the simulator and drag any images (with location data) from your computer into the Photos app on the simulator.

Location data for images in the photo library are accessed via as associated PHAsset. To get the PHAsset for the chosen image, add the following to the picker(_:didFinishPicking:) delegate method you added above.

// Dismiss the picker
picker.dismiss(animated: true)

// Get the selected image asset (we can grab the 1st item in the array since we only allowed a selection limit of 1)
let result = results.first

// Get image location
// PHAsset contains metadata about an image or video (ex. location, size, etc.)
guard let assetId = result?.assetIdentifier,
      let location = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject?.location else {
    return
}

print("📍 Image location coordinate: \(location.coordinate)")

Run the app, navigate to the "Attach Photo" button, and tap to present the image picker. After choosing an image, the picker should dismiss and print the image's location to the console. Copy the latitude and longitude coordinates that print out and enter them into the search field of google maps in your browser. https://www.google.com/maps. For instance, 37.801338333333334, -122.41135333333334. The location found in google maps should match the location where the photo you chose was taken!

Step 4: Get the image from the chosen photo

directly after the code you added above to get the image location (within the delegate method) add the following to get the chosen image as a UIImage. We can then update the image and location on the task.

// Make sure we have a non-nil item provider
guard let provider = result?.itemProvider,
      // Make sure the provider can load a UIImage
      provider.canLoadObject(ofClass: UIImage.self) else { return }

// Load a UIImage from the provider
provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in

    // Handle any errors
    if let error = error {
      DispatchQueue.main.async { [weak self] in self?.showAlert(for:error) }
    
    }

    // Make sure we can cast the returned object to a UIImage
    guard let image = object as? UIImage else { return }

    print("🌉 We have an image!")

    // UI updates should be done on main thread, hence the use of `DispatchQueue.main.async`
    DispatchQueue.main.async { [weak self] in

        // Set the picked image and location on the task
        self?.task.set(image, with: location)

        // Update the UI since we've updated the task
        self?.updateUI()

        // Update the map view since we now have an image an location
        self?.updateMapView()
    }
}

Running the app at this point and picking an image should hide the "Attach Photo" button and show the map view (this UI update happens in the updateUI() method). You should also see the 🌉 We have an image! printed to the console if everything went according to plan with loading the picked image to a UIImage. Also, since we're updating the image property on our Task model, the computed var isComplete will now return true for the given task. Returning to the Task List screen, should should see that the UI has updated to show the task as complete.

💡 The reason why we are able to update a task in the Detail screen and see the updates reflected back in the Task List screen (without explicitly passing back any data from the Detail) is that we are using a class for the Task data model. Unlike structs, which are value types, classes, are reference types so when we update the reference to a given task in the Detail (by updating properties like image and location) the task back in the Task List gets those updates as well as (because it's a class) it's referencing the same instance of the task.
Step 5: Setup the map view
For convenience, The basic UI for the map view has already been added in the starter project. (i.e. map view object added via the storyboard and an outlet created to the respective view controller swift file, in this case, the TaskDetailViewController)


Take a moment to familiarize yourself with the existing UI, open the "Main" Storyboard and navigate to the "Task Detail View Controller". Below the "Attach Photo" button, you'll see there is an MKMapView. Clicking on the "Task Detail View Controller" in the storyboard and opening the "Assistant", should open up the associated TaskDetailViewController swift file. Near the top of the file, you should see an outlet, mapView connecting the map view in the storyboard with the associated property in the backing TaskDetailViewController swift file. Also note that we've added import MapKit framework at the top of the file, which is required to access the map view and associated map related APIs.


Now, let's get the map to zoom in on the area where the chosen photo was taken. In the TaskDetailViewController, locate the updateMapView() method and ad the following.

// Make sure the task has image location.
guard let imageLocation = task.imageLocation else { return }

// Get the coordinate from the image location. This is the latitude / longitude of the location.
// https://developer.apple.com/documentation/mapkit/mkmapview
let coordinate = imageLocation.coordinate

// Set the map view's region based on the coordinate of the image.
// The span represents the maps's "zoom level". A smaller value yields a more "zoomed in" map area, while a larger value is more "zoomed out".
let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
mapView.setRegion(region, animated: true)
AI opportunity

Use AI to brainstorm ideas for your code → Map zoom
Run the app and go through the "Attach Image" flow. After picking an image, the map view should animate to focus around the location where the image was taken. Notice that the map view comes with many of the standard features you associate with maps, such as the ability to pinch to zoom in/out and drag to view different areas. You can adjust how zoomed in the map starts out at by experimenting with setting different span values.
Step 6: Add an annotation
Now that the map view is showing the general area where the photo was taken, let's take things one step further and drop a pin at the precise photo location. We'll do this by creating an annotation with the coordinate of our image and adding it to the map view.


Add the following additional logic in the updateMapView() after setting the map's region.

// Add an annotation to the map view based on image location.
let annotation = MKPointAnnotation()
annotation.coordinate = coordinate
mapView.addAnnotation(annotation)

Run the app, go though the "Attach Image" flow and this time when the map zooms into location, you should see a pin placed on the exact location of where the photo was taken.

Step 7: Use a custom annotation view to display the annotation
For the final step, let’s replace the standard annotation "pin" view with a custom annotation view that displays our picked image. The code which has our custom annotation view is TaskAnnotationView.

Let’s first familiarize ourselves with the starter code in the TaskAnnotationView which is a custom subclass of MKAnnotationView. At first glance, it may appear like there is a lot going on in the TaskAnnotationView, but its mostly just the verbose (and some what tedious) task of creating and setting up programmatic views and autolayout constraints.

The programmatic view hierarchy consists of a container view (the main view), an image view (for showing our image) and another view that we rotate and place on the bottom in order to form the "pin point" that will point to the given location on the map. The only thing particularly unique about subclasses of MKAnnotationView is it's particular init(annotation:reuseIdentifier:) function which we need to override in order to call our own custom setup logic.

In many ways, the MKAnnotationView is like a custom table view cell, and similarly will makes use of a reuseIdentifier in a few places when using it in the map view (as we'll see in just a moment). To make things a bit easier and lessen the chances of mistyping the identifier string, we've added a static var identifier = "TaskAnnotationView" for easy reference.


To get the map view to use our custom TaskAnnotationView we first need to register our custom class with the map view. In the TaskDetailViewController's viewDidLoad() method, add the following (note the use of the reuse identifier mentioned above).

// Register custom annotation view
mapView.register(TaskAnnotationView.self, forAnnotationViewWithReuseIdentifier: TaskAnnotationView.identifier)

Now that the map view is aware of our custom class, we need to create and return an instance of the TaskAnnotationView in one of the map view's delegate methods. This process will look very similar to how we return a custom cell for use in a table view. Still in the viewDidLoad() method, after the logic you added above, set the delegate for the map view.

// Set mapView delegate
mapView.delegate = self

As is a pretty familiar process at this point, we get a compiler error message informing us, Cannot assign value of type 'TaskDetailViewController' to type '(any MKMapViewDelegate)?'. So head down to the bottom of the TaskDetailViewController file (outside the class declaration) and add an extension for TaskDetailViewController that conforms it to the MKMapViewDelegate protocol.

extension TaskDetailViewController: MKMapViewDelegate {

}

Unlike many delegate protocols, the MKMapViewDelegate doesn't have any required methods we need to implement, and so we don't get any errors at this point. Add the following optional delegate method (to the above extension) which will allow us to create and return the custom annotation view for the map view to use when it displays an annotation.

// Implement mapView(_:viewFor:) delegate method.
func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    // Dequeue the annotation view for the specified reuse identifier and annotation.
    // Cast the dequeued annotation view to your specific custom annotation view class, `TaskAnnotationView`
    // 💡 This is very similar to how we get and prepare cells for use in table views.
    guard let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: TaskAnnotationView.identifier, for: annotation) as? TaskAnnotationView else {
        fatalError("Unable to dequeue TaskAnnotationView")
    }

    // Configure the annotation view, passing in the task's image.
    annotationView.configure(with: task.image)
    return annotationView
}

Run the app and go though the "Attach Photo" flow. After picking an image, you should now see a custom annotation added to the map that shows your picked image! 🙌

Step 8: Add button to view the attached photo in another ViewController

Open the main storyboard and in the TaskDetailViewControllerScene add a button labeled "View Photo" under the MKMapView. Attach the "View Photo" button as IBOutlet to the TaskDetailViewController using control-drag gesture from the "View Photo" button to the TaskDetailViewController. Also hide the viewPhotoButton when the task is not complete.

class TaskDetailViewController: UIViewController { 
    ...
    @IBOutlet weak var viewPhoto: UIButton!
    ...
    private func updateUI() {
        ...
        viewPhoto.isHidden = !task.isComplete
   }
}

To create a new ViewController and link task photo data. Go to the main storyboard add a new view controller and an UIImageView to the newly created view controller. Update the UIImageView contraints as you like. Next create a PhotoViewController class file.

 import UIKit
 
 class PhotoViewController: UIViewController {
   var task: Task!
 
   override func viewDidLoad() {
       super.viewDidLoad()
   }
 }

Currently the assistant will not show PhotoViewController for use to attach the UIImageView. In order for us to attach the UIImageView as an IBOutlet to the PhotoViewController, go to the main storyboard update the newly created view controller's custom class with PhotoViewController by going the inspectors, identity tab, class textfield (option-command-4). Click the assistant(control-option-command-enter) to open up the PhotoViewController for you to attach the UIImageView as an IBOutlet named photoView.

import UIKit

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var photoView: UIImageView!
    
    var task: Task!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        photoView.image = task.image
    }
}

In order to share the photo information from TaskDetailViewController to PhotoViewController, we need to go to the main storyboard and create a segue from the "View Photo" button in TaskDetailViewControllerScene to show the PhotoViewControllerScene. Next Update the segue identifier to "PhotoSegue" by going the inspectors, attributes tab, identifier textfield (option-command-5). Last update the TaskDetailViewController to send the task object over the PhotoViewController.

class TaskDetailViewController: UIViewController { 
    ...
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        // Segue to Detail View Controller
     if segue.identifier == "PhotoSegue" {
         if let photoViewController = segue.destination as? PhotoViewController {
             photoViewController.task = task
          }
      }
  }
}

Run the app and go though the "Attach Photo" flow. After picking an image, you should now see the "View Photo" button and by clicking the button you should see your picked image! 🙌



