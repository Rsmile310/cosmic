//
// Copyright (C) 2015 CosmicMind, Inc. <http://cosmicmind.io>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program located at the root of the software package
// in a file called LICENSE.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

public extension UIImage {
	/**
		:name:	contentsOfURL
	*/
	public class func contentsOfURL(URL: NSURL, completion: ((image: UIImage?, error: NSError?) -> Void)?) {
		let request: NSURLRequest = NSURLRequest(URL: URL)
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
			if let v: NSError = error {
				completion?(image: nil, error: v)
			} else if let v: NSData = data {
				completion?(image: UIImage(data: v), error: nil)
			}
		}
	}
}