import UIKit
import SceneKit
import ARKit

//١-
enum PlanetName: String {
    case mercury = "Mercury"
    case venus = "Venus"
    case earth = "Earth"
    case mars = "Mars"
    case jupiter = "Jupiter"
    case saturn = "Saturn"
    case uranus = "Uranus"
    case neptune = "Neptune"
    case pluto = "Pluto"
}

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    //٢-
    var sunNode: SCNNode!
    var sunHaloNode: SCNNode!// الهالة المضيئة للشمس
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.createSun()
        self.createPlanets()
    }
    //٣-
    func createSun() {
        self.sunNode = SCNNode()
        self.sunNode.geometry = SCNSphere(radius: 0.25)
        self.sunNode.position = SCNVector3Make(0, -0.1, -3)
        self.sceneView.scene.rootNode.addChildNode(self.sunNode)
        //غطا الجسم يعني بتجيب الصورة دي وتغطي بيها الجسم او الكوكب وتخليه شمس او ارض او مريخ وهكذا = diffuse
        self.sunNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sun")
// الاشعاع او النور او الهالة = multiply
        // اللي هي جاية من حاجة اسمها الامبينت ambient اللي بتلون الكوكب والملتيبلي جزء منها بتخليه يعمل اشعاع بس
        self.sunNode.geometry?.firstMaterial?.multiply.contents = #imageLiteral(resourceName: "sun")
// intensity = شدة الاشعاع
        self.sunNode.geometry?.firstMaterial?.multiply.intensity = 0.5
        // نوع الضوء
        self.sunNode.geometry?.firstMaterial?.lightingModel = .constant
//اقرا عن wrap in documentation
        self.sunNode.geometry?.firstMaterial?.multiply.wrapS = .repeat
        self.sunNode.geometry?.firstMaterial?.multiply.wrapT = .repeat
        self.sunNode.geometry?.firstMaterial?.diffuse.wrapS = .repeat
        self.sunNode.geometry?.firstMaterial?.diffuse.wrapT = .repeat
        
        self.sunNode.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        
        // sun halo effect
        //نفس الكلام اللي فوق عالشمس بيتعمل عالهالة
        self.sunHaloNode = SCNNode()
        self.sunHaloNode.geometry = SCNPlane(width: 2.5, height: 2.5)
        self.sunHaloNode.rotation = SCNVector4Make(1, 0, 0, Float.pi / 180)
        self.sunHaloNode.geometry?.firstMaterial?.diffuse.contents = #imageLiteral(resourceName: "sun-halo")
        self.sunHaloNode.geometry?.firstMaterial?.lightingModel = .constant
        self.sunHaloNode.geometry?.firstMaterial?.writesToDepthBuffer = false
        self.sunHaloNode.opacity = 0.2
        self.sunNode.addChildNode(sunHaloNode)
        
        //5-
        // setup animation for sun
        self.sunAnimation()
        //6-
        // setup sun light
        self.addLight()
    }
    //11-last step
    func createPlanets() {
        // mecury عطارد
        self.createPlanet(planetName: PlanetName.mercury, radius: 0.02, position: SCNVector3Make(0.4, 0, 0), contents: #imageLiteral(resourceName: "mercury"), rotationDuration: 25, orbitRadius: 0.4)
        
        // venus
        self.createPlanet(planetName: PlanetName.venus, radius: 0.04, position: SCNVector3Make(0.6, 0, 0), contents:#imageLiteral(resourceName: "venus"), rotationDuration: 40, orbitRadius: 0.6)
        
        // earth
        self.createPlanet(planetName: PlanetName.earth, radius: 0.05, position: SCNVector3Make(0.8, 0, 0), contents: #imageLiteral(resourceName: "earth"), rotationDuration: 30, orbitRadius: 0.8)
        
        // mars
        self.createPlanet(planetName: PlanetName.mars, radius: 0.03, position: SCNVector3Make(1.0, 0, 0), contents: #imageLiteral(resourceName: "mars"), rotationDuration: 35, orbitRadius: 1.0)
        
        // jupiter
        self.createPlanet(planetName: PlanetName.jupiter, radius: 0.15, position: SCNVector3Make(1.4, 0, 0), contents: #imageLiteral(resourceName: "jupiter"), rotationDuration: 90, orbitRadius: 1.4)
        
        // saturn
        self.createPlanet(planetName: PlanetName.saturn, radius: 0.12, position: SCNVector3Make(1.68, 0, 0), contents: #imageLiteral(resourceName: "saturn"), rotationDuration: 80, orbitRadius: 1.68)
        
        // uranus
        self.createPlanet(planetName: PlanetName.uranus, radius: 0.09, position: SCNVector3Make(1.95, 0, 0), contents: #imageLiteral(resourceName: "uranus"), rotationDuration: 55, orbitRadius: 1.95)
        
        // neptune
        self.createPlanet(planetName: PlanetName.neptune, radius: 0.08, position: SCNVector3Make(2.14, 0, 0), contents: #imageLiteral(resourceName: "neptune"), rotationDuration: 50, orbitRadius: 2.14)
        
        // pluto
        self.createPlanet(planetName: PlanetName.pluto, radius: 0.04, position: SCNVector3Make(2.319, 0, 0), contents: #imageLiteral(resourceName: "pluto"), rotationDuration: 100, orbitRadius: 2.319)
    }
    //7-
    func createPlanet(planetName: PlanetName, radius: CGFloat, position: SCNVector3, contents: UIImage, rotationDuration: CFTimeInterval, orbitRadius: CGFloat) {

        //بنحدد خصائص الكوكب زي مسار الكوكب ولونه واسمه ونصف القطر والمتيريال وموقعه كل خصائصه من خلال الدالة دي
        
        let planet = SCNNode()
        planet.geometry = SCNSphere(radius: radius)
        planet.position = planetName == .saturn ? SCNVector3Make(0, 0, 0) : position
        planet.geometry?.firstMaterial?.diffuse.contents = contents
        planet.geometry?.firstMaterial?.locksAmbientWithDiffuse = true
        planet.geometry?.firstMaterial?.shininess = 0.1
        planet.geometry?.firstMaterial?.specular.intensity = 0.5
        planet.runAction(SCNAction.repeatForever(SCNAction.rotateBy(x: 0, y: 2, z: 0, duration: 1)))
        
        // add planet around sun //ده الرينج اللي بيكون حوالين الكوكب
        let planetRotationNode = SCNNode()
        if planetName == .saturn {
            let saturnGroup = SCNNode()
            saturnGroup.position = position
            saturnGroup.addChildNode(planet)
            saturnGroup.addChildNode(self.addRingToPlanet(contents: #imageLiteral(resourceName: "saturn_ring")))
            planetRotationNode.addChildNode(saturnGroup)
        } else {
            planetRotationNode.addChildNode(planet)
        }
        //9-
        let animation = CABasicAnimation(keyPath: "rotation")
        animation.duration = rotationDuration
        animation.toValue = NSValue.init(scnVector4: SCNVector4Make(0, 1, 0, Float.pi * 2))
        animation.repeatCount = Float.greatestFiniteMagnitude
        planetRotationNode.addAnimation(animation, forKey: "\(planetName.rawValue) rotation around sun")
        self.sunNode.addChildNode(planetRotationNode)
        //10-
        // orbit // المسار اللي بيمشي فيه
        let planetOrbit = SCNNode()
        planetOrbit.geometry = SCNTorus(ringRadius: orbitRadius, pipeRadius: 0.001)
        planetOrbit.geometry?.firstMaterial?.diffuse.contents = UIColor.white
        planetOrbit.geometry?.firstMaterial?.diffuse.mipFilter = .linear
        planetOrbit.rotation = SCNVector4Make(0, 1, 0, Float.pi / 2)
        self.sunNode.addChildNode(planetOrbit)
    }
    //8-
    //هنضيف الرينج ده لكل الكواكب ماعدا زحل
    func addRingToPlanet(contents: UIImage) -> SCNNode {
        let planetRing = SCNNode()
        planetRing.opacity = 0.4
        planetRing.geometry = SCNCylinder(radius: 0.3, height: 0.001)
        planetRing.eulerAngles = SCNVector3Make(-45, 0, 0)
        planetRing.geometry?.firstMaterial?.diffuse.contents = contents
        planetRing.geometry?.firstMaterial?.diffuse.mipFilter = .linear
        planetRing.geometry?.firstMaterial?.lightingModel = .constant
        return planetRing
    }
    
   
    //6-
    func addLight() {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.color = UIColor.black
        lightNode.light?.type = .omni
        self.sunNode.addChildNode(lightNode)
        
        lightNode.light?.attenuationStartDistance = 0
        lightNode.light?.attenuationEndDistance = 21
        
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1
        lightNode.light?.color = UIColor.white
        self.sunHaloNode.opacity = 0.9
        SCNTransaction.commit()
    }
    //٤-
    func sunAnimation() {
        //نعمل ال difuse
        var animation = CABasicAnimation(keyPath: "contentsTransform")
        animation.duration = 10.0
        //greatestFiniteMagnitude نخلي حجم المقدار كبير
        animation.repeatCount = Float.greatestFiniteMagnitude
        // انيميشن بين نقطتين نقطة بداية ونقطة نهاية
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3))) // CATransform3DMakeScale معدل الضرب كبرت المقدار ٣ مرات يعني
        animation.toValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5)))
        self.sunNode.geometry?.firstMaterial?.diffuse.addAnimation(animation, forKey: "sun_texture")
        
        // نعمل ال multiply
        animation = CABasicAnimation(keyPath: "contentsTranform")
        animation.duration = 30.0
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.fromValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(0, 0, 0), CATransform3DMakeScale(3, 3, 3)))
        animation.toValue = NSValue.init(caTransform3D: CATransform3DConcat(CATransform3DMakeTranslation(1, 0, 0), CATransform3DMakeScale(5, 5, 5)))
        self.sunNode.geometry?.firstMaterial?.multiply.addAnimation(animation, forKey: "sun_texture1")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
